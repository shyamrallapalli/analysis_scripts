Protein Annotation using Interproscan5 webservice
==============================================================
#### Date: 2013 November 22
## Introduction

Aim is to analyze the  predicted proteins for known domains and annotations

## Methods

The protein sequences were submitted to the [InterPRO5 webservice](http://www.ebi.ac.uk/Tools/webservices/services/pfa/iprscan5_rest) using the [run_iprscn5_async_xml_svg.rb](https://github.com/shyamrallapalli/h_pseu_analysis/blob/14926f40c9fc6d4039d8c2c7ee62836548f7c044/Interpro5_scan_go_analysis/run_iprscn5_async.rb) script which wraps the EBI provided Perl script [iprscan5_lwp.pl](iprscan5_lwp.pl) downloaded from [EBI iprscan5_rest service](http://www.ebi.ac.uk/Tools/webservices/download_clients/perl/lwp/iprscan5_lwp.pl).

Command to submit jobs

* `ruby run_iprscn5_async_xml_svg.rb Chalara_fraxinea_ass_s1v1_ann_v1.1.protein.faa submit` 

script submits jobs to webserive in a batch of 30 sequences at 3 minutes intervals (~10,000 proteins sequences would take a day to submit). 

Next morning the same script with following command was used to get results and retrieve annotations

* `ruby run_iprscn5_async.rb Chalara_fraxinea_ass_s1v1_ann_v1.1.protein.faa get_results` 


Interprocan5 produces 5 types of out files and more details can be found at [OutputFormats](https://code.google.com/p/interproscan/wiki/OutputFormats)
Main differences in service from previous version of Interproscan at [InterProScanVersions](https://code.google.com/p/interproscan/wiki/MigratingInterProScanVersions)

These results files were processed to extract domain information for each protein such as PFAM, PANTHER etc.., in addition to Gene Ontology and was wrritten to the file `results.csv`

Header row for results csv file is `"gene","database","id","domain","description"`

SVG files created by Interproscan5 holds interesting information, therefore SVG files for the proteins with GO terms are saved in the folder "SVG-out"

An example of svg file produced
[SVG-out/CHAFR746836.1.1_0032310.1.svg](SVG-out/CHAFR746836.1.1_0032310.1.svg)
  


 
