# Lista de pacotes necessários
packages <- c("tidyverse", "quantmod", "bidask", "readr", "purrr",
              "gt", "writexl", "kableExtra", "knitr")

# Função para instalar pacotes se não estiverem instalados
install_if_missing <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    cat(sprintf("Instalando pacote %s...\n", pkg))
    install.packages(pkg)
  } else {
    cat(sprintf("Pacote %s já está instalado.\n", pkg))
  }
}

# Instalar pacotes faltantes
sapply(packages, install_if_missing)

# Verificar se o pacote bidask está disponível no GitHub
if (!requireNamespace("bidask", quietly = TRUE)) {
  cat("Instalando pacote bidask do GitHub...\n")
  if (!requireNamespace("devtools", quietly = TRUE)) {
    install.packages("devtools")
  }
  devtools::install_github("DavZim/bidask")
}

cat("\nInstalação concluída!\n")