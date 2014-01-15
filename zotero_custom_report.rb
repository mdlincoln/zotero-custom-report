require 'citeproc'
require 'bibtex'
require 'ruby-progressbar'

BIBTEX_PATH = 'report.bib'
OUTPUT_PATH = 'output/report.md'

HEADER = [
	'---',
	'title: Comps Bibliography Notes',
	"date: #{Date.today}",
	'author: Matthew Lincoln',
	'---'
]

bibliography = BibTeX.open(BIBTEX_PATH)
report = File.open(OUTPUT_PATH, "w")
HEADER.each { |e| report.puts e }

prog_bar = ProgressBar.create(:title => "Entries written", :starting_at => 0, :total => bibliography.count, :format => '%c |%b>>%i| %p%% %t')	# => Create a progress bar

bibliography.each do |entry|
	citation = CiteProc.process(entry.to_citeproc, :style => :apa)
	notes = entry[:annote]
	report.puts "### #{citation}"
	report.puts
	report.puts notes
	report.puts

	prog_bar.increment
end


