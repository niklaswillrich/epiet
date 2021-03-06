#' Create an epicurve plot
#'
#' A function to create an epicurve according to EPIET standards
#' @param data data frame which includes dates vector
#' @param dates name of the dates column (string)
#' @param unitOfTimeInDays numeric vector giving bin size
#' @param unitOfLabel character vector giving label
#' @param xTitle title of x-axis
#' @param yTitle title of y-axis
#' @param plotTitle title of plot
#' @param boxes indicates whether to show boxes for cases
#' @param group vector of group membership or "none". Groups are
#' shown in different colors.
#' @param groupHeading
#' @param groupColor list of group colors
#' @param fillcolor color of fill
#'
#' @keywords epidemiology
#' @export
#' @examples
#' plotEpicurve()
#'
################################################################
# The plot function
################################################################
plotEpicurve <- function(data,
                         dates,
                         unitOfTimeInDays=1,
                         unitOfLabel="1 week",
                         xTitle="Date",
                         yTitle="Number of cases",
                         plotTitle="none",
                         boxes="auto",
                         group="none",
                         groupHeading=" ",
                         groupColor= c("#345A8A", "#4F81BD", "grey"),
                         fillColor="steelblue") {
# TODO add group colors for more than 3 groups
# TODO change group variable such that we only have to give the
#       name of the group column instead of a vector


    ################################################################
    # Create data frame
    ################################################################
    df <- data.frame(datevector=data[,dates])

    ################################################################
    # Check dates
    ################################################################
    # http://stackoverflow.com/questions/13450360/how-to-validate-date-in-r
    datetest <- try(as.POSIXct(df$datevector, format= "%d-%m-%Y %H:%M:%S", origin="1970-01-01" ))
    if( class( datetest ) == "try-error" || is.na( datetest ) ) stop( "Incorrect date format: please supply either date, POSIXlt, POSIXct or correctly formated character." )



    ################################################################
    # Create initial plot
    ################################################################
    p <- ggplot2::ggplot(df, ggplot2::aes(datevector))

    ################################################################
    # Test if horizontal lines should be drawn
    ################################################################
    # Generate preliminary plot
    pTest <- p + ggplot2::geom_histogram(binwidth=unitOfTimeInDays*24*60*60)

    if(boxes=="auto"){
        #Check if showBoxesCutOff-criteria is met (Division of the mode with the number of bins)
        boxes <- ifelse((max(ggplot2::ggplot_build(pTest)$data[[1]]$ymax)/nrow(ggplot2::ggplot_build(pTest)$data[[1]]))<2, "yes", "no")
    }

    ################################################################
    # Build the plot when showBoxes is met
    ################################################################
    if(boxes=="yes"){

        # Add data (conditionally with group if group=="none")
        ifelse(group=="none",
               # if group is not set
               p <- p +  ggplot2::geom_histogram(binwidth=unitOfTimeInDays*24*60*60, fill=fillColor, color='white', size=1.2, show.legend=FALSE),
               # if a group vector is given
               p <- p + ggplot2::geom_histogram(binwidth=unitOfTimeInDays*24*60*60, ggplot2::aes(fill=group), size=1.2) +
                   ggplot2::geom_histogram(binwidth=unitOfTimeInDays*24*60*60, ggplot2::aes(fill=group), color='white', size=1.2, show.legend=FALSE) +
                   ggplot2::scale_fill_manual(name=groupHeading, values=groupColor)
        )

        # Add horizontal white lines
        p <- p + ggplot2::geom_hline(yintercept=c(0:max(ggplot2::ggplot_build(pTest)$data[[1]]$ymax)), color="white", size=1.2)
    }

    ################################################################
    # Build the plot when showBoxes is NOT met
    ################################################################
    if(boxes=="no"){
        # Add data (conditionally with group if group=="none")
        ifelse(group=="none",
               # if group is not set
               p <- p +  ggplot2::geom_histogram(binwidth=unitOfTimeInDays*24*60*60, fill=fillColor, show.legend=FALSE),
               # if a group vector is given
               p <- p + ggplot2::geom_histogram(binwidth=unitOfTimeInDays*24*60*60, ggplot2::aes(fill=group)) +
                   ggplot2::scale_fill_manual(name=groupHeading, values=groupColor)
        )
    }


    ################################################################
    # Add the scale of the x-axis
    ################################################################
    p <- p +  ggplot2::scale_x_datetime(breaks = scales::date_breaks(unitOfLabel), labels = date_format("%d.%m"))

    ################################################################
    # Change theme
    ################################################################
    p <- p +  theme_classic()

    ################################################################
    # Add text
    ################################################################
    p <- p + ggplot2::xlab(xTitle)
    p <- p + ggplot2::ylab(yTitle)
    if(plotTitle!="none") {
        p <- p + ggplot2::ggtitle(plotTitle)
    }

    ################################################################
    # Hand over plot
    ################################################################
    p
}

