<meta http-equiv='Content-Type' content='text/html; charset=utf-8' />

To put in the letter:
- Additionally, we edited figure captions for clarity in wording. We believe that this doesn't change what the figure shows, but will be more clear for the reader to understand.
- We also made a few other changes to the supplement. We removed one redundant footnote reference to the "chart" on page 10, and italicized GAP1 to _GAP1_ to be consistent with proper formatting.

Below are our inline responses to the comments:

===

_All of the reviewers thought the paper was well written and that the work was carefully done. Although one of the reviewers (in private comments to the editor) did not feel that the biological results were of broad enough interest. That opinion was not shared by the other two very enthusiastic reviewers._

Thanks! We are really excited to share this work and associated methods with the broader genetics community. The reviews were helpful, especially the very detailed work by Reviewer #1, and we hope it's more clear for readers to readily understand the work done.

_One comment that was common between the unenthusiastic reviewer and another reviewer was that the title of the paper should be changed to one that more specifically reflects the subject matter of the paper, and I agree with this perspective._

We also agree, and have changed the title to:

"BFF identifies mRNA decapping factors important for the rapid repression of GAP1 mRNA upon a nitrogen upshift."
or
"The extent of mRNA destabilization and genetic factors of rapid GAP1 mRNA clearance upon a nitrogen upshift."

_Reviewer's Responses to Questions_

_Comments to the Authors:
Please note here if the review is uploaded as an attachment._

_Reviewer #1: In their ms “Global analysis of gene expression dynamics identifies factors required for accelerated mRNA degradation” Miller an coworkers present a substantial follow-up study on their previous investigation on gene expression dynamics in yeast and report mechanisms for accelerated mRNA degradation._

_The paper is well written and organized and in particular has a great take on data accessibility and reproducible science. While I agree with the overall results and their presentation, I would make the title more specific to the condition that were used in the study._

It is gratifying to see this effort recognized. It was really nice to see that this reviewer spent a lot of attention on this manuscript and associated work.

We will change the title as addressed above.

_As another more general comment, I have realized that the figure labeling is inconsistent (in the text and captions lower case while capitalized in the figure panels) and that the Supplementary Figures are not referenced in stringent order (and S12 not at all in the text)._

We have changed all panel references to uppercase, and re-organized the figure ordering and numbering. Regarding the supplemental figure not being referenced in the text, we found that in the PLoS guidelines it states "We recommend that you cite supporting information in the manuscript text, but this is not a requirement." (http://journals.plos.org/plosgenetics/s/supporting-information)

_Besides this general comment I have only minor questions and suggestions:_

_- P.2 l. 10: modify to “Changes in the mRNA degradation rate have been …”_

We made this change.

_- P.4 l. 60: Is “improvement” a good word here? “enrichment” might be more neutral._

We changed "improvment" to "an increase in nitrogen availability".

_- P.5 l. 90-101 and general PCA: It would be interesting to see also the explained variability of higher PCs and give the details of the PC loadings. This would then also make a smooth transition to the GO analysis. It might be also worth to plot the PC1 values of each sample over time to make the transition more visible._

We have generated the table of PC loadings used for generating the plot as Table S1. We plotted the principal-component loadings against time to better convey the kinetics of the change, and this is available as figure S2 and cited in the text on line 101. We also made a figure plotting the higher principal components, but we do not see a clear trend in the loadings. This plot is available as figure S3, but we do not see a place to reference it in the text.
   
_- P.6 l.128 and 130: additional spaces within the brackets should be deleted._
    
Additional spaces have been removed.

_- The shiny application: as mentioned above, I really appreciate the efforts the authors made for a modern data representation._

_About the shiny application:_

_o It might be worth to give the reader a better guidance within the web application wrt what means “Model based” and “Within sample”. Maybe point to the corresponding information in SI?_

In the corresponding selector option, we added reference to pg. 8 in Appendix 1.

_o While the gene names are given in the empty field it would be good to refer to a list (maybe as popup menu or as text on the webpage?)_

We added the example gene suggestions as text that can be copied and pasted, as "for example:" in the application. We assume this will be more clear for the user.

_o For the BFF panel: I would replace “I could recognize …” by “… was recognized”._

We fixed this, and the application now does not refer to itself in the first person. Instead, it says "This application could [...]", etc. 

_- P.7 l.135: again delete space within brackets._

We made this change.

_- Appendix 1: pp.11: it would be good to mention that this is a heuristic linear model to indicate its potential oversimplification._

We think that's a very clear way to convey that idea, so the section now begins with "Below is our heuristic model [...]".

_o It would be also more educational for less computational readers to explicitly state that the first (old) steady state is given by m_t^o = L^o k_s^o / k_d^o and that the dynamic m_t then follows under the simplifying assumption of an abrupt change in the rates by the given formula._

We thank the reviewer for this suggestion. We have incorporated the suggestion and changed the text:

> "We assume that the culture is at a steady state of L^o 
> \frac{k^o_s}{k^o_d}, from solving the above equation. Solving the above 
> differential equations with the assumption that everything changes once, 
> which is a simplifying assumption but supported by previous studies of 
> transcript stability changes during shifts (Perez-Ortin et. al. 2013 
> review), we expect that m_t should behave as,"

to

> "We assume that the culture is at a steady state of synthesis and 
> degradation at a fixed labeling fraction of L^o.
> From solving the above equation, the signal for a certain mRNA feature 
> we model as reaching and equilibrium of L^o \frac{k^o_s}{k^o_d}. We then 
> assume that changes in stability occur rapidly, which is a simplifying 
> assumption but one supported by previous studies of transcript stability 
> changes during shifts (Perez-Ortin et. al. 2013 review), we then expect 
> that m_t should change as a result of changes in the labelling parameter 
> or rates of synthesis or degradation as"

_o Within the model investigation, it would be good to clarify the parameters better. I assume that the “K_d” in the captions of Fig. 4 and 5 are actually not dissociation constants like K_d=k+/k- but sould refer to k_d^n = 0.1 k_d^o ? But how is k_d^o chosen? And how does this relate to literature?_

We recognized the potential for confusion and added this line in the second paragraph of page 11 to state:

> "IMPORTANTLY, k_d does not refer to the dissociation constant in
this document, but rather the specific rate of degradation of a transcript."

k_d^o is not chosen, but rather fit in the model. We've added the line:

> "Importantly, this approach estimates both k_o and k_d from the data, by 
> using the mock-treatment dataset."

to express this. The discussion of the relation to the literature for this range of fit values is found in the main text pg. 7 line 144.

_o After figure 4: change “Is this a reasonable rates for modeling here?” to “Is this a reasonable rate for modeling here?”_

We made this change.

_o Specify Basal rate and Total rate in Fig. 5 wrt to the model._

We agree that we did not make it explicitly clear, so we included the exact terms in the caption to facilitate the comparison. 

_o And how do you conclude to the 17% mentioned in the main text p.7 l.136 ? In the SI 13.3% are mentioned?_

Thank you for identifying this typo. We've corrected in the main text.

- _Furthermore the bibliography is missing for referenced literature!_

References are provided as footnotes in the supplement, as we did not see any guidance regarding reference styles in the supplement.

- _P.7 Table 1: give p-val for fold change here._

We assume this comment is seeking additional clarity about the threshold for classifying destabilized transcripts, so we changed the title and added descriptive text to re-iterate the criteria used:

> "Summary of mRNA stability and changes upon the upshift. Destabilized transcripts were identified using the cut-offs of a FDR < 0.01 and at least a doubling of estimated degradation rates."

_- P.8 l.165: again a space in the brackets._

We've reformatted this to have the literature citation in the preceding text.

_- P.8 l. 169: change “shows” to “indicate”._

Fixed.

_- P.8 l.180: delete “and”._

Fixed. Sharp eyes.

_- P.9 l.205 and 208 space typos._

Fixed.

_- S14 Fig. space in ylabel._

Fixed.

_- S16 Fig. cut in the upper right labels. Centralize the scale bar in the lower panels._

We fixed the cut letter. Moving the scale bars would require re-processing the image from scratch, and we do not believe that it will strongly contribute to the interpretation of the data, thus we did not made this change.

_- P.12 l.292 -299: This paragraph and its reasoning should be extended. In the current form it is hard to judge if this is rather speculation or real indication._

To address this, and other comments from Reviewer 2, we rewrote this paragraph:

> "Identification of an initiation factor subunit mutant with defects in GAP1 
> mRNA clearance suggested that translation control may impact stability 
> changes. Therefore we deleted the 5’ UTR and 3’ UTR of GAP1. Whereas the 3’ 
> UTR deletion does not have an effect, the 5’ UTR deletion exhibits the 
> phenotype of reduced GAP1 mRNA before the upshift and a reduced rate of 
> transcript clearance following the upshift (Fig 5e). We observed a similar 
> phenotype with an independent deletion of 152bp upstream of the GAP1 start 
> codon (S17 Fig). This indicates that cis-elements responsible for the rapid 
> clearance of GAP1 are unlikely to be located in the 3’ UTR and instead may be 
> exerting an effect at the 5’ end of the mRNA, and this is discussed further in 
> the Discussion."

_- P.16 l.415: Missing S1 before “Table”._

Fixed.

_- P. 18 l.484: S1 Appendix does not have a real rational as referred in this line. Would help the readability to have this explicitly in the table of content of the S1 Appendix._

Now that this is pointed out, we've realized that the rationale for the interrupted chase design is actually explained in the text (avoiding issues of glutamine affecting transport activity), so have removed the reference to rationale from this line.

_o Appendix S1 has a weird line break at the end of p.6._

Fixed. 

_- P. 20 l.523: The BFF is specified in S2 and not S1 Appendix. And again it hasn’t a rational section that would help the reader – or is the Motivation section meant to be this? Then name it accordingly._

Fixed the reference to point to the correct appendix, and changed "design rationale" to "motivation" in the text.

_- A2 Appendix:
o p.2 What does “PBS[^pbs]” mean?_

This is a typo of an omitted footnote. We've replaced it, with link to DOI for protocol.

_o P.2 change “classic greying” to “typical greying”_

Fixed.

_o Inconsistent foot note formate (some with space other without!)_

We have attempted to make footnotes of uniform format.

_o Ytics in Fig. 6-11 could be synchronized._

This is very true, and would facilitate comparisons across figures. However, we are trying to focus on the comparisons within the figures, and in order to make those comparisons the scale must be appropriate for the range of the values in that figure. Since we are trying to compare primarily within the figure, we left these as scaled for each figure independently, given the numeric values are printed and gridded so the interested reader can make those comparisons. 

_o Again the bibliography is missing for referenced literature (like in S1 Appendix)!_

We mentioned before, but we believe that the use of footnotes adequately directs the user to the appropriate reference, and allows us to use URLs and DOIs for referencing more directly the software pages.

_- For all figure labels: check space typos!_

It is true that the spacing is slightly inconsistent in some places, but this appears to be artifacts of the \LaTeX  engine optimizing spacing to typeset the text with even left and right margins. Hence, certain lines have large amounts of spacing to make the widths even. We believe that the even margins left and right are worth the occasional extra whitespace, and hope it is clear and presentable to the reader.

_- Fig. 3 A: suboptimal y-label. B: space typo in brackets of x-label (and why not a.u. as in other labels?). C: What does “Visible” refers to? To Bright field? Should be clarified!_

Indeed, and by removing the extra whitespace the complete label fits on one line for A ! B: fixed and introduced contraction. C: "Visible" refers to bright field illumination viewed through an objective designed for polarized light. This was a novice microscopy mistake. While we believe it is suboptimal imaging, it is sufficient for establishing approximately where the cell is in visible light spectra, and thus is sufficient for comparing to the properly imaged fluorescent channel. Seeing as this wasn't described in the methods, we added a section to the methods: 

> "Microscopy post-FACS 
> 
> Cells hybridized with GAP1 mRNA FISH Affymetrix probes (as described in 
> detail in S2 Appendix) were sorted with a BD FACSAria II based on emission 
> area from a 660/20nm filter with a 633nm laser activation into four gates 
> for the 3-minute post-shift timepoint. These were sorted using PBS sheath 
> fluid at room-temperature into poly-propylene FACS tubes, then vortexed and 
> drop of each was settled on poly-lysine treated coverslips. These were 
> imaged on a DeltaVision scope, with FISH fluorescence detected in the ”Cy5” 
> channel (632/22nm excitation, 676/34nm emission) and the ”Visible” light 
> collected as bright-field illumination captured with a polarized objective. 
> Raw images available in the ”microscopy” zip archive (Availability of data 
> and analysis scripts)."

_If the authors address these minor issues, I would like to see this ms published with PLoS Genetics._

We agree!

_Reviewer #2: There are no attachments._

_The authors assembled state of the art technologies and used them effectively to open a new area of study in transcriptional regulation on a genome-wide basis. The work is replete with answers (provided as supplementary information) to each assumption the authors made thereby making their arguments more convincing. Though the text is somewhat dense for someone not familiar with the detailed analytical procedures the authors describe, this did not detract from understanding their reasoning and conclusions._

This is very good to hear. We are very interested in making these methods available for broader use, and are hopeful that this work can contribute to the use of transcriptome dynamics as a genetic marker for untangling gene regulatory networks.

_There are four major reasons that this article will be of general scientific interest: (1) The work adds two well-supported new perspectives to the mechanisms associated with Nitrogen Catabolite Repression of nitrogen-responsive genes and their products, mRNA destabilization and potential 5' UTR participation in this process. In addition the authors have identified known and new transacting factors associated with GAP1 mRNA clearance upon initiation of nitrogen repression. (2) The authors have carefully analyzed the limitations of general pulse chase labelling procedures and developed effective solutions to those problems. (3) They clearly demonstrate that the overall physiology of the cell is separated and precedes the overall effects of nitrogen shift on growth of the cell. This will likely necessitate re-interpretation of some experimental data in which growth was used as the reporter of the outcomes of a nitrogen upshift and the cellular components regulating it. (4) The overall sophisticated technologies they have used in concert will be applicable to a wide variety of biological systems._

_There are one significant and three minor errors that the authors should consider._

_1) The font sizes on almost all of the figures are far too small to be read even when the pdf is enlarged. This is a distraction as the reader works to figure out what is being measured._

This was a large problem, and we have remade every figure, aiming to have proper sized font and with decent spacing. Note that in response to Reviewer #1, we made a few more supplemental figures. No large structural changes were made to the pre-existing figures, and we believe that the old figures convey the same concept but with additional clarity.

_2) Line 294 there is a comma missing after the word "effect". If this is not the case, the sentence should be rewritten for greater clarity._

This was fixed in an previously mentioned re-write of this paragraph. It was a typo.

_3) LIne 295. "exhibit" should be "exhibits"_

Same as above.

_Reviewer #3: The paper from Miller et al shows a potentially interesting study on the gene expression kinetics after N upshift in yeast. The work has been done carefully and it could be useful for other researchers because it contains many technical improvements both in wet an informatics experiments. However, I think that the novelty of the results and conclusions obtained does not support the publication on PLOS Genetics._

_Other comments:_
_1) Page 6. The sentence "As 4tU labeling requires nucleotide transport..." Is confuse. 4tU is not a nucleotide neither it is a nucleoside (as 4sU, 4-thioruridine). Therefore it is know that it can be assimilated by wild type S. cerevisiae. As explained in Sun et al, Genome Res 22 (2012): We used 4-thiouracil (4tU) instead of 4sU for Sc RNA labeling, because it is taken up by Sc (Munchel et al. 2011) without expression of a nucleoside transporter (Miller et al. 2011). Therefore I cannot see why the authors the protocol of puls and chase before the addition of Gln._

This is a mistake in terminology that we missed, and is an example of peer review improving a paper. We changed this to refer to 4-thiouracil as the nucleobase it is.

The chase of the label before perturbation is important because nucleotide labeling requires a change to the balance of labeled/non-labeled nucleobases/nucleosides/nucleotides inside the cell. We cite Hein et al 1995 that characterizes how the Rsp5 ubiquitin ligase mediates the post-translational degradation of Gap1p after ammonium addition or of Fur4p (the uracil permease) upon stress conditions. We modified this section to also cite the group's previous paper (Volland et al 1994) that characterizes how Fur4p post-translational stability depends on nutrient availability. We hope this version of that section is more clear in our choice to sidestep these potential issues by using the interrupted chase design.

Here is the re-written text:

> "As a 4tU labeling experiment requires uracil transport, which may be altered 
> upon stresses or a change in nitrogen-availability [50, 51], we designed 
> experiments such that following complete 4tU labeling and metabolism to 
> nucleotides the chase was initiated prior to addition of glutamine or water 
> (mock)."

_2) The text contains deviations from the main message that the authors use to explain how they have solved technical problems or inconsistencies. In spite that all of them may be quite useful for the researcher they make difficult to follow the main arguments or conclusions. I recommend to transfer many of them to M&M and keep the Results section more straightforward._

This is a useful stylistic comment, but would require extensive re-working of the text. We believe a lot of the broader interest of this article is in the advances in pooled genetic screens that are detailed here, and we agree with Reviewer #2 that "this did not detract from understanding their reasoning and conclusions". 
