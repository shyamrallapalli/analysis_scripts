###### Date 2013 November 18
#### RNA-seq assembly blastn to GFF 

I would like to create a GFF from RNA-seq assemblies as a priliminary genemodels on to the genome assemblies of interest.

I have used [Ashwellthorpe_ATU1 RNA-seq Trinity assembly](https://github.com/ash-dieback-crowdsource/data/blob/master/ash_dieback/fraxinus_excelsior/Ashwellthorpe_ATU1/assemblies/ATU1_Trinity.fasta) for blast analysis

blastn from Blast+ verison 2.2.28 is used

RNA-seq assemblies are aligned against a databse created from genome scaffolds of [tree35_Nornex_TGAC_assembly_v1](https://github.com/ash-dieback-crowdsource/data/blob/master/ash_dieback/fraxinus_excelsior/tree35/assemblies/gDNA/Fraxinus_excelsior_Nornex_s1v1/Fraxinus_excelsior_Nornex_s1v1.tar.gz/Fraxinus_excelsior_Nornex_s1v1-scaffolds.fa)

using following command

`source blast+-2.2.28; blastn -db Fraxinus_excelsior_tree35-scaffolds -query ATU1_Trinity.fasta -max_target_seqs 5 -outfmt 7 -out ATU1_RNA-seq_Trinity_tree35_Nornex_scaffolds_blastplus.blastn`

Resulting [ATU1_RNA-seq_Trinity_tree35_Nornex_scaffolds_blastplus.blastn](https://github.com/ash-dieback-crowdsource/data/blob/master/ash_dieback/fraxinus_excelsior/Ashwellthorpe_ATU1/blasts/ATU1_blastn_tree35_TGACv1/blastn.txt) file is used as input for generate a GFF file to be used with Fraxinus_excelsior_Nornex_s1v1-scaffolds.fa

[blastn-to-GFF.rb](https://github.com/shyamrallapalli/analysis_scripts/commits/fa848a52419290473c36306e1f828f60ee6741d0/blastn_to_gff/blastn-to-GFF.rb) script is written to extract alignments of RNA-seq assemblies as exons.

Exons from each invidivual assembly are pooled and presented as mRNA

RNA-seq assembly with more than one identical alignment over different contigs were ignored with initial script.




