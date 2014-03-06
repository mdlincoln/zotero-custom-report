###########
#
# This script takes a BibLaTeX file exported from Zotero and generates
# a PDF report of citations and their notes, sorted by tag.
#
###########

require 'citeproc'
require 'bibtex'

BIBTEX_PATH = 'report.bib'
OUTPUT_PATH = 'output/'
Dir.mkdir(OUTPUT_PATH) unless Dir.exists?(OUTPUT_PATH)

# Add any desired frontmatter to the report file
report = File.open("#{OUTPUT_PATH}/report.latex", "w")
HEADER = [
]
HEADER.each { |e| report.puts e }

puts "Loading bibliography..."
bibliography = BibTeX.open(BIBTEX_PATH, :strip => false)
storage = []
key_list = []

puts "Generating citations..."

# Generate a citation via CiteProc for each bibliographic entry, and
# retrieve&format its annotations. These are put into a temporary array until
# the list of unique tags is determined

bibliography.each do |entry|
	date = entry[:year].to_i
	author = entry[:author]
	title = entry[:title]
	citation = "#{date}: #{author}, \\em{#{title}}"
	notes = entry[:annote]
	# Exported notes only have single line breaks between paragraphs. LaTeX
	# requires double line breaks
	notes = notes.gsub(/$/,"\n\n") unless notes.nil?
	# Retrieve the entry keyword and store it in a temporary array
	key = entry[:keywords].to_s
	key_list << key

	storage << {
		:key => key,
		:citation => citation,
		:notes => notes,
		:date => date
	}
end

key_list.uniq!
puts "#{key_list.count} unique sections."

# Write a section for each key, and put individual citations with that key
# into each subsection
puts "Writing out to latex..."
for key in key_list do
	report.puts "\\section{#{key}}"
	storage.select{ |value| value[:key] == key }.sort_by!{ |value| value[:date] }.each do |entry|
		report.puts "\\subsubsection{#{entry[:citation]}}"
		report.puts entry[:notes]
	end
end

puts "Generating pdf..."
`pandoc #{OUTPUT_PATH}/report.latex -o #{OUTPUT_PATH}/report.pdf --latex-engine=xelatex --toc --toc-depth=1`
`open #{OUTPUT_PATH}/report.pdf`
