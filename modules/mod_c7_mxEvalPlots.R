
mxEvalPlots_UI <- function(id) {
  ns <- NS(id)
  tagList(
    selectInput(ns('mxEvalSel'), label = "Select evaluation statistic",
                choices = list("Select Stat..." = '', "average AUC test" = 'avg.test.AUC', 
                               "average AUC diff" = 'avg.diff.AUC', "average OR mtp" = 'avg.test.orMTP',
                               "average OR 10%" = 'avg.test.or10pct', "delta AICc" = 'delta.AICc'), 
                selected = 'avg.test.AUC'),
    HTML('<hr>'),
    strong("Download Maxent evaluation plot (.png)"), br(), br(),
	actionButton(ns('dlMxEvalPlot_G'), "Get in Galaxy"),
    downloadButton(ns('dlMxEvalPlot'), "Download")
  )
}

mxEvalPlots_MOD <- function(input, output, session, rvs) {
  reactive({
    if (is.null(rvs$mods)) {
      rvs %>% writeLog(type = 'error', "Models must first be run in component 6.")
      return()
    }
    if (is.null(input$mxEvalSel)) {
      rvs %>% writeLog(type = 'error', "No statistic selected for plotting.")
      return()
    }
    
    # record for RMD
    rvs$mxEvalSel <- input$mxEvalSel
    rvs$comp7 <- isolate(c(rvs$comp7, 'mxEval'))
    
	
	# handle downloads for Maxent Evaluation Plots png in Galaxy
	observeEvent(input$dlMxEvalPlot_G ,{
	owd <- setwd(tempdir())
	on.exit(setwd(owd))
	name<-paste0(spName(), "_maxent_eval_plot.png")
	filename<-gsub(" ","_",name,fixed = TRUE)
	png(file=filename)
	evalPlot(rvs$modRes, input$mxEvalSel)
        dev.off()
	
	command<-paste('python /opt/python/galaxy-export/export.py',filename,'auto')
	system(command)
	})
    # handle downloads for Maxent Evaluation Plots png
    output$dlMxEvalPlot <- downloadHandler(
      filename = function() {paste0(spName(), "_",rvs$mxEvalSel,"_EvalPlot.png")},
      content = function(file) {
        png(file)
        evalPlot(rvs$modRes, input$mxEvalSel)
        dev.off()
      }
    )
    
    evalPlot(rvs$modRes, input$mxEvalSel)
  })
}
