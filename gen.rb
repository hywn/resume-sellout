#!/usr/bin/env ruby

text = File.read 'resume.md'
css  = File.read 'style.css'

output = text.scan(/(.+)\n(---+|===+)\n((?:(?:\t|\*).+\n?|\n)+)/).map { |title, line, contents|

	# process links
	contents.gsub!(/\[(.+?)\]\((.+?)\)/) { "<a href='#{$2}'>#{$1}</a>" }

	html = ''

	# add section headers (on side or <h1>)
	html     = "<div class=first>#{title}</div>"                      if line.match /---+/
	contents = "<div class=second><h1>#{title}</h1></div>" + contents if line.match(/===+/)

	# convert section content into seconds (with floating thirds)
	html + contents.gsub(/\* (.+)\n?((?:\t.+\n?)*)/) {

		main, sub = $1, $2

		sub.gsub!(/\t- (.+)/m) { $1.strip.gsub("\n", '<br />') }

		main.sub! /{(.+?)}/, ''
		lang = $1
		main.sub! /<([ \d\-Present,]+?)>$/, ''
		date = $1

		'<div class=second><div class=header>%s%s</div>%s</div>%s' % [
			main,
			("<span class=lang>#{lang}</span>" if lang),
			("<blockquote>#{sub}</blockquote>" if not sub.empty?),
			("<div class=third>#{date}</div>"  if date)
		]

	}

}

File.write 'docs/index.html', "<style>#{css.gsub /\s+/, ' '}</style><body>#{output.join '<div class=filler></div>'}</body>"