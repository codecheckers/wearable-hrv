## Documentation
## https://cran.r-project.org/web/packages/zen4R/vignettes/zen4R.html

## Zenodo deposit; see vignette("codecheck_overview.Rmd")

library(codecheck)
library(yaml)
library(zen4R)
## This assumes your working directory is the codecheck directory

yaml_file <-  "../codecheck.yml"

metadata = read_yaml(yaml_file)

## To interact with the Zenodo API, you need to create a token.  This should
## not be shared, or stored in this script.  Here I am using the Unix password
## tool pass to retrieve the token.
my_token = system("pass show codechecker-token", intern=TRUE)

## make a connection to Zenodo API
zenodo <- ZenodoManager$new(token = my_token)


my_rec <- get_zenodo_record(zenodo, metadata)

## Careful -- make sure your yaml file is saved before running this next chunk; if there is not
## zenodo record, it will create one.
if ( is.null(my_rec)) {
  my_rec <- zenodo$createEmptyRecord()
  codecheck:::add_id_to_yml(my_rec$id, yaml_file) ## may want to have warning on this.
  metadata <- read_yaml(yaml_file)  ## re-read metadata as there is now a proper ID.
}


## Now update the zenodo record with any new metadata
my_rec <- upload_zenodo_metadata(zenodo, my_rec, metadata)

## If you have already uploaded the certificate once, you will need to
## delete it via the web page before uploading it again.
zenodo$uploadFile("codecheck.pdf", record=my_rec)

## You may also create a ZIP archive of of any data or code files that
## you think should be included in the CODECHECK's record.

## Now go to zenodo and check the record (the URL is printed
## by set_zenodo_metadata() ) and then publish.



## TODO: check community added.


## find the list of languages supported
zenodo$getLanguages()

l <- zenodo$getLicenses()


##ved with validation errors:
## Publication date =   
##Resource type:M Publication / Preprint

##Publisher: 
## https://zenodo.org/help/versioning -- this is nice!
## myrec$setResourceType("software")

## community
com <- zenodo$getCommunityById("codecheck")

zenodo$submitRecordToCommunities(my_rec, "codecheck")
