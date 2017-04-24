#! /bin/bash 
## using the vcf files and the human refernce genome
## obtain the alignment for the any region for individuals from 1000 genomes phase 3.

## change this to your chromosome number
chr=$1
## change this to the start position of your region
start=$2
## change this to the end position of your region
end=$3

## Takes in string of selected species returned from python GUI
specieslist=$4

## Takes in string of selected populations returned from python GUI
populationlist=$5


echo "The region of your interest: chr"$chr":"$start"-"$end" for "$populationlist" population(s). Have fun!"
mkdir ../../../VCFtoTree_Output

##Human Condition Met
## prepare 1000 genome vcf file
/usr/local/bin/tabix -h -f http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/ALL.chr$chr.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz $chr:$start-$end > chr$chr.START$start.END$end.vcf

vcffile=chr$chr.START$start.END$end.vcf

## prepare reference sequence for your chosen chromosome
/usr/local/bin/wget http://hgdownload.soe.ucsc.edu/goldenPath/hg19/chromosomes/chr$chr.fa.gz
gunzip -c chr$chr.fa.gz > chr$chr.fa
/usr/local/bin/samtools faidx chr$chr.fa
/usr/local/bin/samtools faidx chr$chr.fa chr$chr:$start-$end > REF_chr$chr.START$start.END$end.fa

ref=REF_chr$chr.START$start.END$end.fa

python Code/vcf2fasta_erica.py $vcffile $ref $start $end $populationlist ALI_1000HG.fa log.txt

##If array only contains human
if [ $specieslist -eq 'Human' ];
then
	python Code/fas2phy.py ALI_1000HG.fa ALI_final.phy
	Code/raxmlHPC-PTHREADS-SSE3 -T 2 -n YourRegion -s ALI_final.phy -mGTRGAMMA -p 235 -N 2

	mv RAxML_bestTree.YourRegion RAxML_bestTree.YourRegion.newick
	
	mv RAxML_* ../../../VCFtoTree_Output/
	mv AL* ../../../VCFtoTree_Output/
	mv error* ../../../VCFtoTree_Output/
	mv REF* ../../../VCFtoTree_Output/
	mv chr* ../../../VCFtoTree_Output/
	mv *.vcf ../../../VCFtoTree_Output/
	mv *.vcf.gz.tbi ../../../VCFtoTree_Output/
	open ../../../VCFtoTree_Output/

##Else if other species selected
else
	touch ALI_altainean.fa
	touch ALI_vindijanean.fa
	touch ALI_den.fa
	touch ALI_panTro4Ref_hg19.fa
	touch ALI_rheMac3Ref_hg19.fa
	

##If neadertal in array
	if [[ $specieslist == *"Neanderthal"* ]]
	then
		## prepare Altai neanderthal vcf files
		/usr/local/bin/wget http://cdna.eva.mpg.de/neandertal/altai/AltaiNeandertal/VCF/AltaiNea.hg19_1000g.$chr.mod.vcf.gz
		/usr/local/bin/tabix -h -f AltaiNea.hg19_1000g.$chr.mod.vcf.gz
		/usr/local/bin/tabix -h -f AltaiNea.hg19_1000g.$chr.mod.vcf.gz $chr:$start-$end > Altainean_chr$chr.START$start.END$end.vcf
		
		vcffile_altainean=Altainean_chr$chr.START$start.END$end.vcf
		
		python Code/vcf2fasta_AltaiNean_Den_rmhetero_erica.py $vcffile_altainean $ref $start $end ALI_altainean.fa Indels_Altai.txt
	fi	

##If Vindija neanderthal in array
    if [[ $specieslist == *"Vindija"* ]]
    then
        ## prepare Vindija vcf file
        /usr/local/bin/wget http://cdna.eva.mpg.de/neandertal/Vindija/VCF/Vindija33.19/chr$chr\_mq25_mapab100.vcf.gz
        /usr/local/bin/tabix -h -f chr$chr\_mq25_mapab100.vcf.gz
        /usr/local/bin/tabix -h -f chr$chr\_mq25_mapab100.vcf.gz $chr:$start-$end >  Vindijanean_chr$chr.START$start.END$end.vcf

        vcffile_vindijanean=Vindijanean_chr$chr.START$start.END$end.vcf

        python Code/vcf2fasta_AltaiNean_Den_rmhetero_erica.py $vcffile_vindijanean $ref $start $end ALI_vindijanean.fa Indels_Vindija.txt
    fi


##If denisova in array
	if [[ $specieslist == *"Denisova"* ]] 
	then
		## prepare Denisovan vcf files
		/usr/local/bin/tabix -h -f http://cdna.eva.mpg.de/neandertal/altai/Denisovan/DenisovaPinky.hg19_1000g.$chr.mod.vcf.gz $chr:$start-$end > Den_chr$chr.START$start.END$end.vcf

		vcffile_den=Den_chr$chr.START$start.END$end.vcf
		
		python Code/vcf2fasta_AltaiNean_Den_rmhetero_erica.py $vcffile_den $ref $start $end ALI_den.fa Indels_Denisova.txt
	fi

##If chimp in array
	if [[ $specieslist == *"Chimp"* ]]
	then
		# getting Chimpanzee(panTro4) reference, mapped to hg19
		/usr/local/bin/wget http://hgdownload.soe.ucsc.edu/goldenPath/hg19/vsPanTro4/axtNet/chr$chr.hg19.panTro4.net.axt.gz
		gunzip -c chr$chr.hg19.panTro4.net.axt.gz > chr$chr.hg19.panTro4.net.axt
		python Code/Map_panTro4Ref2hg19.py chr$chr.hg19.panTro4.net.axt $chr $start $end ALI_panTro4Ref_hg19.fa
	fi

##If RM in array
	if [[ $specieslist == *"Rhesus macaque"* ]]
	then
		# getting Rhesus(RheMac3) reference, mapped to hg19
		/usr/local/bin/wget http://hgdownload.soe.ucsc.edu/goldenPath/hg19/vsRheMac3/axtNet/chr$chr.hg19.rheMac3.net.axt.gz
		gunzip -c chr$chr.hg19.rheMac3.net.axt.gz > chr$chr.hg19.rheMac3.net.axt	
		python Code/Map_rheMac3Ref2hg19.py chr$chr.hg19.rheMac3.net.axt $chr $start $end ALI_rheMac3Ref_hg19.fa
	fi

	##May cause error if not found
	# add gaps from log.txt
	cat ALI_altainean.fa ALI_vindijanean.fa ALI_den.fa ALI_panTro4Ref_hg19.fa ALI_rheMac3Ref_hg19.fa >> ALI_temp.fa
	#rm ALI_altainean.fa
	#rm ALI_vindijanean.fa
	#rm ALI_den.fa
	#rm ALI_panTro4Ref_hg19.fa
	#rm ALI_rheMac3Ref_hg19.fa
	python Code/add_gap.py ALI_temp.fa log.txt $start $end ALI_othergenomes_wgap.fa

	cat ALI_othergenomes_wgap.fa ALI_1000HG.fa >> ALI_final.fa
	rm ALI_temp.fa


	# building tree
	rm ALI_final.phy
	python Code/fas2phy.py ALI_final.fa ALI_final.phy
	
	chmod +x Code/raxmlHPC-PTHREADS-SSE3
	Code/raxmlHPC-PTHREADS-SSE3 -T 2 -n YourRegion -s ALI_final.phy -mGTRGAMMA -p 235 -N 2

	mv RAxML_bestTree.YourRegion RAxML_bestTree.YourRegion.newick
    mv Indels_* ../../../VCFtoTree_Output/
    mv log.txt ../../../VCFtoTree_Output/
	mv RAxML_* ../../../VCFtoTree_Output/
	mv AL* ../../../VCFtoTree_Output/
	mv error* ../../../VCFtoTree_Output/
	mv REF* ../../../VCFtoTree_Output/
	mv chr* ../../../VCFtoTree_Output/
	mv *.vcf ../../../VCFtoTree_Output/
	mv *.vcf.gz.tbi ../../../VCFtoTree_Output/
	mv Code/

	open ../../../VCFtoTree_Output/
	echo "All done, Erica is a genius."
fi









