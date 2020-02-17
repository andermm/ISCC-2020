options(crayon.enabled=FALSE)
library(DoE.base)
library(tidyverse)

set.seed(0)
ISCC2020 <- fac.design(factor.names = list(
  apps = c("bt", "ep", "cg", "mg", "lu",
           "sp", "is", "ft", "intel", "alya"),
  instance = c("A8", "A10")),
  replications=30,
  randomize=TRUE)

ISCC2020 %>%
  select(-Blocks) %>%
  mutate(number=1:n()) -> ISCC2020
write_csv(ISCC2020, "experimental_project.csv")
