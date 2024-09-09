# KruskalWallis4PiCRUST
A program to produce visuzlizations from PiCRUST output. 
## Inputs 
Input file is a slightly altered version of the unzipped pred_metagenome_unstrat_descrip.tsv.gz file outputted by PiCRUST. Often times R is unable to deal with both the amount of genes and also the length of gene names within the .tsv file. Thus in excel we can break the file down into two parts as follows:<br>
`output.txt`: The KO gene and abundance information with imputted treatments.<br>
`labels.txt`: The KO gene and descriptions. <br>
Examples of both are present in the repository.
## Usage 
If your input files have different names than output.txt and labels.txt you can change the names in lines 10 and 18 respectively. <br>
You must change the "A", "B", "C" in line 25 to your treatment groups <br> 
Unless otherwise stated, output images will be named KOXXXX.png, and output .txt file with significant p-values will be called p-values.txt. This can be changed in lines 61 and 80 but is not a necessary change. 
## Outputs
Example outputs are given in the repository: <br>
Image outputs include: `K00001.jpg` & `K00005.jpg` <br>
P-value output is `p-values.txt`