#' Import MS2Soft attributes as list
#'
#' Imports the attributes  list from an input file containing the metadata required
#' to download data
#' @param path path to the attributes list file and class table, usually left
#' as default if using recomended folder structure
#' @returns A list containing the attributes required for the workflow
# Export this function
#' @export
ms2_attributes <-
  function(path = "inputs/input_file.xlsx"){

    attr_table <- readxl::read_excel(path)

    list(analysis_type = attr_table[attr_table$attribute == "analysis_type", 2] %>% dplyr::pull(),
         main_url = attr_table[attr_table$attribute == "main_url", 2] %>% dplyr::pull(),
         dl_path = attr_table[attr_table$attribute == "downloads_folder", 2] %>% dplyr::pull(),
         dot = attr_table[attr_table$attribute == "dot", 2] %>% dplyr::pull(),
         offset = attr_table[attr_table$attribute == "offset", 2] %>% dplyr::pull(),
         a = attr_table[attr_table$attribute == "a", 2] %>% dplyr::pull(),
         class_table = readxl::read_excel(path,
                                          sheet = "class_table"))
  }
