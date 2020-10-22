#!/usr/bin/env ruby

text = File.read 'resume.md'
css  = File.read 'style.css'

output = text.scan(/(.+)\n(---+|===+)\n((?:(?:\t|\*).+\n?|\n)+)/).map { |title, line, contents|

	# process links
	contents.gsub!(/\[(.+?)\]\((.+?)\)/) { "<a href=\"#{$2}\">#{$1}</a>" }

	html = ''

	# add section headers (on side or <h1>)
	html     = "<div class=\"first\">#{title}</div>"                      if line.match /---+/
	contents = "<div class=\"second\"><h1>#{title}</h1></div>" + contents if line.match(/===+/)

	# convert section content into seconds (with floating thirds)
	html + contents.gsub(/\* (.+)\n?((?:\t.+\n?)*)/) {

		main, sub = $1, $2

		sub.gsub! /«(.+)»\n/, %q{<blockquote class='sellout'>\1</blockquote>}
		sub.gsub!(/\t- (.+)/m) { $1.strip.gsub("\n", '<br />') }

		main.gsub! /<([ \d\-Present,]+?)>$/, ''

		'<div class="second">%s%s</div>%s' %
		[
			main,
			("<blockquote>#{sub}</blockquote>" if not sub.empty?),
			('<div class="third">%s</div>' % $1 if $1)
		]

	}

}

File.write 'docs/index.html', "<style>#{css}</style><body>#{output.join '<div class="filler"></div>'}</body>"
