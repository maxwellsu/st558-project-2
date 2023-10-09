rmarkdown::render("cfbd_vignette.Rmd", 
                  output_format = "github_document",
                  output_file = "README.md",
                  output_options = list(
                    df_print = "paged"
                  )
                )
