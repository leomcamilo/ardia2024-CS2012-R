#install.packages("rmarkdown")

# Importar códigos de empresas novamente
company_codes <- read_csv("company_codes.csv")

# Função para ler dados de arquivos CSV
read_company_data <- function(symbol) {
  file_path <- paste0("prices-companies/", symbol, ".csv")
  if (file.exists(file_path)) {
    read_csv(file_path)
  } else {
    message("Arquivo não encontrado para: ", symbol)
    NULL
  }
}

# Aplicar a função a todos os códigos de empresas usando purrr::map
company_data_list <- company_codes$Company_Code %>%
  map(~ read_company_data(.x))

# Extrair os resultados bem-sucedidos e Nomear a lista com os códigos das empresas
company_data_clean <- company_data_list %>%
  map("result") %>%
  set_names(company_codes$Company_Code)

# Verificar quais downloads falharam
errors <- company_data_list %>%
  map("error") %>%
  keep(~ !is.null(.x))

if (length(errors) > 0) {
  print("Alguns downloads falharam:")
  print(errors)
} else {
  print("Todos os dados foram baixados com sucesso.")
}






# Agrupar as empresas com maiores médias de volume diários e selecionar os 30% maiores e 30% menores

# Calcular a média de volume para cada empresa
company_volumes <- company_data_clean %>%
  # Extrair a coluna de Volume (coluna 5) de cada dataframe
  map_dbl(~ mean(.x[[5]], na.rm = TRUE))

# Converter os resultados para um dataframe para melhor manipulação
company_volumes <- tibble(
  Company = names(company_data_clean),
  Mean_Volume = company_volumes
)

# Definir os percentis de 30% e 70%
volume_30 <- quantile(company_volumes$Mean_Volume, 0.3, na.rm = TRUE)
volume_70 <- quantile(company_volumes$Mean_Volume, 0.7, na.rm = TRUE)

# Atribuir cada empresa a um grupo com base na média de volume
company_volumes <- company_volumes %>%
  mutate(
    Group = case_when(
      Mean_Volume <= volume_30 ~ "Low Volume (Bottom 30%)",
      Mean_Volume > volume_70 ~ "High Volume (Top 30%)",
      TRUE ~ "Middle Volume (40%)"
    )
  )

# Empresas de baixo volume (Bottom 30%)
low_volume <- company_volumes %>%
  filter(Group == "Low Volume (Bottom 30%)") %>%
  pull(Company)

# Empresas de alto volume (Top 30%)
high_volume <- company_volumes %>%
  filter(Group == "High Volume (Top 30%)") %>%
  pull(Company)

# Criando um company_data_clean_high_volume e company_data_clean_low_volume
company_data_clean_high_volume <- company_data_clean[high_volume]
company_data_clean_low_volume <- company_data_clean[low_volume]

