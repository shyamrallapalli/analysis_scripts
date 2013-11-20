#!/usr/bin/ruby
# encoding: utf-8
#

def return_aln_parameters_query (hash)
	data = Hash.new {|h,k| h[k] = {} }
	hash.each { |a,b|
		hash[a].each { |c, d|
			array = c.split("\t") 
			if data[a].key?(:alnlegth) == true
				data[a][:alnlegth] = c[3].to_i + data[a][:alnlegth]
			else
				data[a][:alnlegth] = c[3].to_i
			end
			if data[a].key?(:mismatch) == true
				data[a][:mismatch] = c[4].to_i + data[a][:mismatch]
			else
				data[a][:mismatch] = c[4].to_i
			end
			if data[a].key?(:gap) == true
				data[a][:gap] = c[5].to_i + data[a][:gap]
			else
				data[a][:gap] = c[5].to_i
			end
		}
	}
	data
end

def return_best_contig_aln (hash2)
	contigid = ""
	hash2.each { |key, value|
		if contigid =~ /\w/
			if hash2[key][:alnlegth] > hash2[contigid][:alnlegth] && hash2[key][:mismatch] < hash2[contigid][:mismatch] && hash2[key][:gap] < hash2[contigid][:gap]
				contigid = key
			elsif hash2[key][:alnlegth] == hash2[contigid][:alnlegth] && hash2[key][:mismatch] == hash2[contigid][:mismatch] && hash2[key][:gap] == hash2[contigid][:gap]
				contigid = ""
			end
		else
			contigid = key
		end
	}
	contigid
end


blast = Hash.new {|h,k| h[k] = Hash.new {|h,k| h[k] ={} } }

lines = File.read(ARGV[0])
results = lines.split("\n")
results.each do |string|
  if string !~ /^#/ 
	blastdata = string.split("\t")
	blast[blastdata[0]][blastdata[1]][string] = 1
#			q_id	s_id	  blast-data
#	puts string
  end
end

# New file is opened to write the gff info
outfile = File.new("Blastn_to_gff3.gff", "w")
	outfile.puts "##gff-version 3"

#blast.each { |k1,v1|
#	subjectid = ""
#	if k1 =~ /\_len\:(\d*)\_path/
#		length = $1
#		puts "#{k1}\t#{length}\n"
#		data = return_aln_parameters_query (blast[k1])
#	end
#	puts "printing subject id"
#	puts subjectid

blast.each { |k1,v1|
	data = return_aln_parameters_query (blast[k1])
	subjectid = return_best_contig_aln (data)

	if subjectid =~ /\w/
		limits = Hash.new {|h,k| h[k] = {} }
		blast[k1][subjectid].each { |key2, value2|
			array2 = key2.split("\t")
			aln_end = array2[9].to_i
			aln_start = array2[8].to_i
			puts "#{k1}\t#{aln_end}\t#{aln_start}\n"			
			if aln_end < aln_start
				puts "antisense-alignment: end position less than start"
				puts "#{k1}\t#{aln_end}\t#{aln_start}\n"
				outfile.puts "#{subjectid}\tTRINITY\texon\t#{aln_end}\t#{aln_start}\t.\t-\t.\tParent=#{k1}\n"
				limits[:strand] = "-"
				if limits.key?(:start) == true
					if limits[:start] > aln_end
						limits[:start] = aln_end
					end
				else
					limits[:start] = aln_end
				end
				if limits.key?(:stop) == true
					if limits[:stop] < aln_start
						limits[:stop] = aln_start
					end
				else
					limits[:stop] = aln_start
				end
			elsif aln_end > aln_start
				puts "sense-alignment: end position greater than start"
				puts "#{k1}\t#{aln_end}\t#{aln_start}\n"
				outfile.puts "#{subjectid}\tTRINITY\texon\t#{aln_start}\t#{aln_end}\t.\t+\t.\tParent=#{k1}\n"
				limits[:strand] = "+"
				if limits.key?(:start) == true
					if limits[:start] > aln_start
						limits[:start] = aln_start
					end
				else
					limits[:start] = aln_start
				end
				if limits.key?(:stop) == true
					if limits[:stop] < aln_end
						limits[:stop] = aln_end
					end
				else
					limits[:stop] = aln_end
				end
			end
		}
		outfile.puts "#{subjectid}\tTRINITY\tmRNA\t#{limits[:start]}\t#{limits[:stop]}\t.\t#{limits[:strand]}\t.\tID=#{k1}\n"
	end
}
