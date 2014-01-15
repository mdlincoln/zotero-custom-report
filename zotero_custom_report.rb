puts "Initializing..."

require 'citeproc'
require 'bibtex'
require 'ruby-progressbar'

BIBTEX_PATH = 'report.bib'
OUTPUT_PATH = 'output/report.latex'

report = File.open(OUTPUT_PATH, "w")
HEADER = [
	"\\tableofcontents"
]
HEADER.each { |e| report.puts e }

puts "Loading bibliography..."
bibliography = BibTeX.open(BIBTEX_PATH, :strip => false)
storage = []
key_list = []

puts "Generating citations..."
prog_bar = ProgressBar.create(:title => "Entries written", :starting_at => 0, :total => bibliography.count, :format => '%c |%b>>%i| %p%% %t')	# => Create a progress bar

bibliography.each do |entry|
	citation = CiteProc.process(entry.to_citeproc, :style => :apa)
	notes = entry[:annote]
	notes = notes.gsub(/$/,"\n\n") unless notes.nil?
	key = entry[:keywords].to_s
	key_list << key

	storage << {
		:key => key,
		:citation => citation,
		:notes => notes
	}
	prog_bar.increment
end

puts "#{key_list.count} total keys"
key_list.uniq!
puts "#{key_list.count} different keys."

puts "Writing out to latex..."
for key in key_list do
	report.puts "\\section{#{key}}"
	storage.select { |value| value[:key] == key }.each do |entry|
		report.puts "\\subsection{#{entry[:citation]}}"
		report.puts entry[:notes]
	end
end
	

puts "Generating pdf..."
`pandoc output/report.latex -o output/report.pdf --latex-engine=xelatex`
`open output/report.pdf`
