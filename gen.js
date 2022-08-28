#!/usr/bin/env -S deno run --allow-read --allow-write

const slurp = f => Deno.readFile(f).then(b => new TextDecoder().decode(b))

Function.prototype.after = function(f) {
	return (...args) => this(f(...args))
}

const opt = ([a, b], thing) => thing ? `${a}${thing}${b}` : ''

const contentf = (_, content, langm, datem) =>
	`<div class=content>${content}</div>
	${opt`<div class=lang>${langm}</div>`}
	${opt`<div class=date>${datem}</div>`}`

const process = text => text
	.replace(/(\w.+)\n===+/g, '<h1>$1</h1>')
	.replace(/(\w.+)\n---+/g, (_, one) => `<h2>${one}</h2>`)
	.replace(/\[(.+?)\]\((.+?)\)/g, "<a href='$2'>$1</a>")
	.replace(/^\* (.+?) ?(?:\{(.+)\})? ?(?:\<([Present\d- ]+)\>)?$/mg, contentf) // epic
	.replace(/^\t- (.+)/mg, '<blockquote class=detail>$1</blockquote>')

const text = await slurp('resume.md')
const output = text.split(/\n\n\n+/).map(process).join('<div class=spacer></div>')
const html = `<meta name=viewport content='width=device-width, initial-scale=1'><link href=style.css rel=stylesheet>` + output

await Deno.writeFile
	( 'docs/index.html'
	, new TextEncoder().encode(html)
	)
