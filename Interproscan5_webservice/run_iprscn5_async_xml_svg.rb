#!/usr/bin/ruby
# encoding: utf-8
#

require 'rubygems'
require 'pp'
require 'json'
require 'csv'
require 'bio'
require 'barmcakes'
require 'fileutils'
require 'nokogiri'

### Submits sequences in a groups of 30 and wait for 4 minutes between submissions and iterates until all sequences are submitted
def submit_bundles
  File.open("submitted.log", "w").write("")   # A log file to include submitted records
  File.open("done.log", "w").write("")        # A log file to include processed records
  File.open("error.log", "w").write("")       # A log file to include error records
  File.open("results.csv", "w").write("\"gene\",\"database\",\"id\",\"domain\",\"description\"\n")
  FileUtils.mkdir("SVG-out")
  
  Bio::FastaFormat.open(ARGV[0]).each_slice(30).each_with_index do |seqs, batch|
    string = seqs.collect {|s| s.to_s}.join("")
    job = `echo '#{string}' | perl ./iprscan5_lwp.pl --email ghanasyam.rallapalli@tsl.ac.uk --async --goterms --multifasta -`
    #puts job
    File.open("submitted.log", "a+").write("#{job}\n")
    sleep(180)
  end
end

## Read submitted job list
def read_submitted
  lines = File.open("submitted.log", "r").read
  lines.split("\n")
end

## Read completed and data extracted job list
def read_done
  lines = File.open("done.log", "r").read
  lines.split("\n")
end

## Get protein name from fasta file
def get_genename(fasta_file)
  geneid1 = ""
  file = Bio::FastaFormat.open(fasta_file)
  file.each do |entry|
    geneid1 = entry.entry_id
  end
  geneid1
end

## Get protein annotations from XML
def get_annotations_xml(xmlfile)
  annos = Hash.new {|h,k| h[k] = Hash.new {|h,k| h[k] ={} } }
  @doc = Nokogiri::XML(File.open(xmlfile))
  geneid = (@doc.xpath("//xmlns:xref"))[0]['id']

  (@doc.xpath("//xmlns:go-xref")).each do |p|
    ## Descriptions might have ["] characters that would results unexpected comma separation, so replace with [']
    info = p['category'] + '","' + (p['name']).gsub(/\"/, "'")
    annos[geneid][p['db']][p['id']] = info
  end

  (@doc.xpath("//xmlns:signature")).each do |p|
    library = ""
    p.children.each do |k|
      k.to_s =~ /signature-library-release.*library="(.*)"/
      test = $1
		  if test =~ /\w/
        library = test
      end
    end
    info = ""
    next unless p['name'] =~ /\w/
    if p['desc'] !~ /\w/
      info = (p['name']).gsub(/\"/, "'")
    else
      info = (p['name']).gsub(/\"/, "'") + '","' + (p['desc']).gsub(/\"/, "'")
    end
    annos[geneid][library][p['ac']] = info
  end
  
  annos
end

## Get results for submitted job
def get_result_for(job)
  FileUtils.mkdir("#{job}")
  FileUtils.cd("#{job}")
  system("perl ../iprscan5_lwp.pl --polljob --jobid #{job}")

  genename = get_genename("#{job}.sequence.txt")						# input sequence file ends with "jobid".sequence.txt
  if File.file?("#{job}.xml.xml")
    puts "got the xml file"
    annos = get_annotations_xml("#{job}.xml.xml")						# webservice out put as xml file ends with "jobid".xml.xml
    # puts "#{genename}"
    outfile = File.open("../results.csv", "a+")

    annos[genename].each {|k,v|
  	 annos[genename][k].each {|k2,v2|
     # puts "\"#{geneid}\",\"#{k}\",\"#{k2}\",\"#{v2}\""
  	 outfile.puts "\"#{genename}\",\"#{k}\",\"#{k2}\",\"#{v2}\""  }
    }
	  puts "#{job}.svg.svg"
    FileUtils.cp("#{job}.svg.svg", "../SVG-out/#{genename}.svg")
  else
    File.open("../error.log", "a").write("#{job}\t#{genename}\n")  
	end
  FileUtils.cd("../")
  FileUtils.rm_rf("#{job}")
  File.open("done.log", "a").write("#{job}\n")
end

## Check if the submitted job is completed
def check_if_done
    submitted = read_submitted
    done = read_done

    submitted.each do |job|
      next unless job =~ /\w/
      next if done.include? job
      if `perl iprscan5_lwp.pl --status --jobid #{job}` =~ /FINISHED/
        get_result_for job
        sleep(5)
      end
    end 
    
end

if ARGV[1] == 'submit'
  submit_bundles
elsif ARGV[1] == 'get_results'
  check_if_done
end
