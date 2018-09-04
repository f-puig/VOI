voi2D<-function(NMR_matrix,thresh,minvoi) {
  
# Create a matrix of 0 (below thresh) and 1 (above thresh).
cols <- ncol(NMR_matrix)-1
rows <- nrow(NMR_matrix)-1
evaluated <- matrix(ncol=cols,nrow=rows, data=rep(1,cols*rows))
evaluated[which(NMR_matrix[2:(rows+1),2:(cols+1)]>=thresh)] <- 0
  
# Data initialization 
arraypeak <- list()
indexes <- vector()
peaks <- 1
m=0

# Look for connected pixels in temp matrix.
for (row in 1 : rows) {
  for (col in 1 : cols) {
    #  3.1 Pixels will be evaluated once. If they have already been
    #   evaluated, they will be ignored.
    if (evaluated[row,col] == 1) {
      next    

    # 3.2 If the current pixel was not evaluated, and intensity is
    #  above threshold, then the pixel is counted.
    } else {
      candidate <- c(row, col)
      m=m+1;
      while (length(candidate)!=0) {
      # Copy 'candidate' data to 'pos' and empty 'candidate' content.
      # pos includes the pixel positions within a peak and it is increasing at every iteration.
      if (length(candidate)>2) {
        pos <- candidate[1,]
        candidate <- candidate[-1,]
      } else {
        pos <- candidate
        candidate <- NULL
      }
        
      # If we have visited this pixel, don't count it again.
      if (evaluated[pos[1],pos[2]]){
        next
      }
      
      # Otherwise, check the pixel and store the position.
      evaluated[pos[1],pos[2]] <- 1
      if (isTRUE(all.equal(length(arraypeak),peaks))){
        arraypeak[[peaks]] <- c(arraypeak[[peaks]],sub2ind(rows, pos[1], pos[2]))
      } else {
        arraypeak[[peaks]] <- sub2ind(rows, pos[1], pos[2])
      }
      
      # Check the 8 neighbouring positions. 
      # Stablish the positions.
      aa <- meshgrid(c(pos[2]-1,pos[2],pos[2]+1), c(pos[1]-1,pos[1],pos[1]+1))
      pos_y <- c(aa$x1)
      pos_x <- c(aa$y1)
      
      # Discard locations outside the matrix limits.
      offlimits <- which(pos_x < 1 | pos_x > rows | pos_y < 1 | pos_y > cols)
      if(length(offlimits)!=0){
        pos_y<-pos_y[-offlimits]
        pos_x<-pos_x[-offlimits]
      }
      
      # Discard locations already checked.
      excluded<-vector()
      for (j in 1:length(pos_x)) {
        if (evaluated[pos_x[j], pos_y[j]]==1){
          excluded<-c(excluded,j)
        }
      }
      if(length(excluded)!=0){
        pos_y <- pos_y[-excluded]
        pos_x <- pos_x[-excluded]
      }
      # Add to 'candidate'.
      candidate <- rbind(candidate, cbind(pos_x, pos_y))
      }
    # Start with the new region
    peaks <- peaks + 1
    }
  }
}

# 4. List of indexes (VOIs) and array_peaks2
array_peaks <- list()
k<-1

for (i in 1:length(arraypeak)){
  if (length(arraypeak[[i]])>= minvoi) {
    indexes <- c(indexes,arraypeak[[i]])
    array_peaks[[k]] <- arraypeak[[i]]
    k <- k+1
  }
}

indexes<-sort(indexes)

# 5. Create the filtered_NMR variable
filtered_NMR <- matrix(nrow=rows+1, ncol=cols+1, data=rep(0,(rows+1)*(cols+1)))
filtered_NMR[1,2:(cols+1)] <- NMR_matrix[1,2:(cols+1)]
filtered_NMR[2:(rows+1),1] <- NMR_matrix[2:(rows+1),1]
pos_sortx <- ((indexes-1) %% rows) + 1
pos_sorty <- floor((indexes-1) / rows) + 1
indexes2 <- sub2ind(rows+1, pos_sortx+1, pos_sorty+1)
filtered_NMR[indexes2] <- NMR_matrix[indexes2]

# 6. Create the VOImatrix variable
VOImatrix <- matrix(nrow=3, ncol=length(indexes))
VOImatrix[1,] <- NMR_matrix[indexes2]
VOImatrix[2,] <- NMR_matrix[1,pos_sorty+1]
VOImatrix[3,] <- NMR_matrix[pos_sortx+1,1]

output<-list()
output$filtered_NMR<-filtered_NMR
output$VOImatrix<-VOImatrix
output$indexes<-indexes
output$array_peaks<-array_peaks

return(output)
}
    
sub2ind<-function(rows, ro, co){
inds <- (co-1)*rows + ro
return(inds)
}
    
meshgrid<-function(x,y){
  m <- length(x)
  n <- length(y)
  x1 <- matrix(rep(x,each=n),nrow=n)
  y1 <- matrix(rep(y,m),nrow=n)
  out1<-list()
  out1$x1<-x1
  out1$y1<-y1
  return(out1)
}
