#!/usr/bin/ruby
# encoding: utf-8
#

require 'rubygems'
require 'bio'

gffdata = Hash.new {|h,k| h[k] = Hash.new {|h,k| h[k] ={} } }
transcript = Hash.new {|h,k| h[k] = Hash.new {|h,k| h[k] ={} } }


gff3 = Bio::GFF::GFF3.new(File.read(ARGV[0]))
gff3.records.each do | record |
  elementlength = (record.end).to_f - (record.start).to_f + 1  # Add 1 since first number is inclusive of the feature

  if gffdata.key?(record.feature)
	gffdata[record.feature] = (gffdata[record.feature]).push(elementlength)
  else
	array = []
	gffdata[record.feature] = array.push(elementlength)
  end

  if record.feature == 'exon'
    geneid = record.get_attributes('Parent')
  	if  transcript[geneid[0]].key?(:cDNA_transcript) == true
		transcript[geneid[0]][:cDNA_transcript] = transcript[geneid[0]][:cDNA_transcript] + elementlength
	else
		transcript[geneid[0]][:cDNA_transcript] = elementlength
	end
  end
  if record.feature == 'CDS'
    geneid = record.get_attributes('Parent')
  	if  transcript[geneid[0]].key?(:CDS_transcript) == true
		transcript[geneid[0]][:CDS_transcript] = transcript[geneid[0]][:CDS_transcript] + elementlength
	else
		transcript[geneid[0]][:CDS_transcript] = elementlength
	end
  end
end

transcript.each { |k,v|
  transcript[k].each { |k1, v1|
  	if gffdata.key?(k1)
		gffdata[k1] = (gffdata[k1]).push(v1)
  	else
		array = []
		gffdata[k1] = array.push(v1)
  	end
  }
}

# New file is opened to write the gff info
outfile = File.new("gff3_stats_out.txt", "w")
	outfile.puts "Feature\tMean Size\tMinimum\tMaximum\tCount\tTotal Length\n"
gffdata.each { |key, value|
#	puts key
#	puts value
	minimum = value.min
	maximum = value.max
	total = value.inject{|total, x| total + x}
	count = value.length
	mean = (total/count).round(0)
	outfile.puts "#{key}\t#{mean}\t#{(minimum).to_i}\t#{(maximum).to_i}\t#{count}\t#{(total).to_i}\n"
}
