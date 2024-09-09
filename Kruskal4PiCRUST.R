#Reset variables and packages
rm(list = ls(all = TRUE))
invisible(lapply(paste0('package:', names(sessionInfo()$otherPkgs)), detach, character.only=TRUE, unload=TRUE))

#Load needed packages
library(tidyverse)
library(dplyr)
library(ggpubr)
library(rstatix)
library(gtools)

#Load input data
data <- read_delim(
  'output.txt',
  delim = "\t",
  escape_double = FALSE,
  trim_ws = FALSE,
  lazy = TRUE
)

labels <- read_delim(
  'labels.txt',
  delim = "\t",
  escape_double = FALSE,
  trim_ws = FALSE,
  lazy = TRUE
)

data$Treatment <- ordered(data$Treatment, levels = c("A", "B", "C"))
levels(data$Treatment)

pvaluek = list()
pvaluedSX = list()
pvaluedSXX = list()
pvaluedXXX = list()
pvalueName = list()
pvalueLabel = list()

# Run Kruskal Wallis, Dunns, and plot
for (i in 3:ncol(data)) {
  new = pull(data, i)
  k = kruskal.test(new ~ data$Treatment)
  print(paste0(i, k$p.value))
  if(k$p.value < 0.05) {
    print(colnames(data)[[i]])
    print(k$p.value)
    dunn = data.frame(data$Treatment, new)
    stat.test <- dunn_test(dunn, new ~ data.Treatment) 
    stat.test$pval = stars.pval(stat.test$p)
    stat.test
    if ((stat.test$p[1]<0.05) & (stat.test$p[2]>0.05) & (stat.test$p[3]<0.05) & (stat.test$statistic[1] != stat.test$statistic[3])) {
      plot = ggplot(data, aes(x=Treatment, y=new)) + 
        geom_boxplot(aes(fill = Treatment), show.legend = FALSE) +
        labs(x=labels[labels$`function` == colnames(data)[i],2][[1]], y="Gene Abundance") + 
        scale_fill_manual(values=c("blue", "orange", "pink")) +
        geom_dotplot(binaxis='y', stackdir='center', dotsize=0.9) +
        theme(axis.line = element_line(color='black', size=0.7),
              plot.background = element_blank(),
              panel.background = element_rect(fill="white"),
              panel.grid.major = element_blank(),
              panel.grid.minor = element_blank(),
              panel.border = element_blank(),
              axis.text=element_text(size=12, color="black"),
              axis.title=element_text(size=14)) + 
        stat_pvalue_manual(stat.test, label = "pval", hide.ns = "p", y.position = max(new)+max(new)/10, step.increase = 0.05)
      print(plot)
      ggsave(paste0(colnames(data)[i], ".jpg", sep=''), width=8, height=4)
      pvaluek = c(pvaluek, k$p.value)
      pvaluedSX = c(pvaluedSX, stat.test$p[1])
      pvaluedSXX = c(pvaluedSXX, stat.test$p[2])
      pvaluedXXX = c(pvaluedXXX, stat.test$p[3])
      pvalueName = c(pvalueName, paste0(colnames(data)[[i]]))
      pvalueLabel = c(pvalueLabel, labels[labels$`function` == colnames(data)[i],2][[1]])
    }
  }
}
pvaluek = as.character(pvaluek)
pvaluedSX = as.character(pvaluedSX)
pvaluedSXX = as.character(pvaluedSXX)
pvaluedXXX = as.character(pvaluedXXX)
pvalueName = as.character(pvalueName)
pvalueLabel = as.character(pvalueLabel)

#Output p-values to file
output = data.frame(pvalueName, pvalueLabel, pvaluek, pvaluedSX, pvaluedSXX, pvaluedXXX)
colnames(output) = c("Gene Name", "Description", "Kruskal-Wallis P-Value", "Dunn's Control vs Treatment 1", "Dunn's Control vs Treatment 2", "Dunn's Treatment 1 vs Treatment 2")
write_delim(as.data.frame(output), file="p-values.txt", delim="\t")