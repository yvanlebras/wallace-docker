respPlots_UI <- function(id) {
  ns <- NS(id)
  tagList(
    strong("Download response plot (.png)"), br(),
    checkboxInput(ns('dlRespPlotAll'), "All response plots?"),
    actionButton(ns('dlRespPlot_G'), "Get in Galaxy"),
    downloadButton(ns('dlRespPlot'), "Download")
  )
}

respPlots_MOD <- function(input, output, session, rvs) {
  reactive({
    if (is.null(rvs$mods)) {
      rvs %>% writeLog(type = 'error', "Models must first be run in component 6.")
      return()
    }

    # record for RMD
    rvs$comp7 <- isolate(c(rvs$comp7, 'resp'))
    
    modCur <- rvs$mods[[rvs$modSel]]
	
    # handle downloads for Response Plots png in Galaxy
    observeEvent(input$dlRespPlot_G ,{
    owd <- setwd(tempdir())
    on.exit(setwd(owd))
	
    name<-paste0(spName(), "_", rvs$envSel, "_response.png")
    filename<-gsub(" ","_",name,fixed = TRUE)
    png(file=filename)
    if (input$dlRespPlotAll == TRUE) {
        dismo::response(modCur)
    } else {
        dismo::response(modCur, var = rvs$envSel)  
    }
    dev.off()	
    command<-paste('python /opt/python/galaxy-export/export.py',filename,'auto')
    system(command)
    })
    # handle downloads for Response Plots png
    output$dlRespPlot <- downloadHandler(
      filename = function() {paste0(spName(), "_", rvs$envSel, "_response.png")},
      content = function(file) {
        png(file)
        if (input$dlRespPlotAll == TRUE) {
          dismo::response(modCur)
        } else {
          dismo::response(modCur, var = rvs$envSel)  
        }
        dev.off()
      }
    )
    
    dismo::response(modCur, var = rvs$envSel)
  })
}
