# informalexample 5.43 of section 5.4.1 
# (informalexample 5.43 of section 5.4.1)  : Data engineering and data shaping : Multi-table data transforms : Combining two or more ordered data frames quickly 

library("data.table")


# Generating data (derived from preceding example scripts)

productTable <- wrapr::build_frame(
  "productID", "price" |
    "p1"       , 9.99    |
    "p2"       , 16.29   |
    "p3"       , 19.99   |
    "p4"       , 5.49    |
    "p5"       , 24.49   )


salesTable <- wrapr::build_frame(
  "productID", "sold_store", "sold_online" |
    "p1"       , 6           , 64            |
    "p2"       , 31          , 1             |
    "p3"       , 30          , 23            |
    "p4"       , 31          , 67            |
    "p5"       , 43          , 51            )

productTable2 <- wrapr::build_frame(
  "productID", "price" |
    "n1"       , 25.49   |
    "n2"       , 33.99   |
    "n3"       , 17.99   )

productTable$productID <- factor(productTable$productID)
productTable2$productID <- factor(productTable2$productID)


# add an extra column telling us which table
# each row comes from
productTable_marked <- productTable
productTable_marked$table <- "productTable"
productTable2_marked <- productTable2
productTable2_marked$table <- "productTable2"

# combine the tables
rbind_base <- rbind(productTable_marked, 
                    productTable2_marked)
rbind_base



# Note: Using ':=' leads to a per-group column calculation 'in-place',
# that is inside of current data.table and therefore each row gets the
# corresponding per-group calculation assigned

dt <- as.data.table(rbind_base)
grouping_column <- "table"
dt[ , max_price := max(price), by = eval(grouping_column)]

print(dt)

##    productID price         table max_price
## 1:        p1  9.99  productTable     24.49
## 2:        p2 16.29  productTable     24.49
## 3:        p3 19.99  productTable     24.49
## 4:        p4  5.49  productTable     24.49
## 5:        p5 24.49  productTable     24.49
## 6:        n1 25.49 productTable2     33.99
## 7:        n2 33.99 productTable2     33.99
## 8:        n3 17.99 productTable2     33.99


# Using '=' leads to a new data.table in summary table form

dt2 <- dt[ , .(max_price = max(price)), by = grouping_column]

print(dt2)


# Using ':=' with backticks on a 'list' of variables for 'in-place' calculations

dt3 <- as.data.table(rbind_base)
grouping_column <- "table"
dt3[ , `:=`(max_price = max(price), min_price = min(price)), by = eval(grouping_column)]

print(dt3)


# Using ':=' inside of a 'list' of variables for 'in-place' calculations => NOT working!

dt4 <- as.data.table(rbind_base)
grouping_column <- "table"
dt4[ , .(max_price := max(price), min_price := min(price)), by = eval(grouping_column)]

print(dt4)

