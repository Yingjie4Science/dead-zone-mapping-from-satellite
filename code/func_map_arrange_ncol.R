


## This function aims to plot multiple maps in one column 


func_map_arrange_ncol <- function(plot_list, n_plots, ncols, nrows, h, filename) {  #@ the total number of plots
  
  png(filename = filename, pointsize = 12, width = 7, height = h*nrows/ncols, units="in", res = 600)
  

  ## create page and add plots
  grid.newpage()
  pushViewport(viewport(layout = grid.layout(
    nrow = nrows,
    ncol = ncols
  )))
  
  z = 0
  for (i in 1:nrows) {
    for (j in 1:ncols) {
      z = z + length(i)
      print(z)
      print(plot_list[z], vp = viewport(layout.pos.row = i, layout.pos.col = j))
    }
  }
  
  

  ## save image
  dev.off()
}
