# Getting started with gsDesignTune

This vignette demonstrates dependency-aware grid search over group
sequential designs using gsDesignTune.

``` r
library(gsDesign)
library(gsDesignTune)
```

## Basic designs with `gsDesignTune()`

[`gsDesignTune()`](https://nanx.me/gsDesignTune/reference/gsDesignTune.md)
wraps
[`gsDesign::gsDesign()`](https://keaven.github.io/gsDesign/reference/gsDesign.html)
for tuning basic group sequential designs.

``` r
job <- gsDesignTune(
  k = 3,
  test.type = 2,
  alpha = 0.025,
  beta = 0.10,
  timing = tune_values(list(c(0.33, 0.67, 1), c(0.5, 0.75, 1))),
  upper = SpendingFamily$new(
    SpendingSpec$new(sfLDOF, par = tune_fixed(0)),
    SpendingSpec$new(sfHSD, par = tune_seq(-4, 4, length_out = 3))
  )
)

job$run(strategy = "grid", parallel = FALSE)
res <- job$results()
head(res)
#>   upper_setting       timing upper_fun upper_par config_id status error_message
#> 1  function.... 0.33, 0.....    sfLDOF         0         1     ok          <NA>
#> 2  function.... 0.5, 0.75, 1    sfLDOF         0         2     ok          <NA>
#> 3  function.... 0.33, 0.....     sfHSD        -4         3     ok          <NA>
#> 4  function.... 0.5, 0.75, 1     sfHSD        -4         4     ok          <NA>
#> 5  function.... 0.33, 0.....     sfHSD         0         5     ok          <NA>
#> 6  function.... 0.5, 0.75, 1     sfHSD         0         6     ok          <NA>
#>   warnings                        cache_key design_rds    call_args k test.type
#> 1     <NA> cb2610fb0a4d16425894a20d0b0d5191       <NA> 3, 2, 0..... 3         2
#> 2     <NA> 9a19b655ab2e76bc9718cb78cc437a7f       <NA> 3, 2, 0..... 3         2
#> 3     <NA> a596bf2736e423e3be03e7a44ede0efa       <NA> 3, 2, 0..... 3         2
#> 4     <NA> 1efc77f880a86f1016c08b31ff8b0e9a       <NA> 3, 2, 0..... 3         2
#> 5     <NA> d5b205647b9b1c31fa1ff28050f0bca3       <NA> 3, 2, 0..... 3         2
#> 6     <NA> 93a3a5c5b477581dbce058508a1ed2e3       <NA> 3, 2, 0..... 3         2
#>   alpha beta          n_I final_n_I      upper_z      lower_z      upper_p
#> 1 0.025  0.1 0.333977....  1.012053 3.7307, .... -3.7307,.... 1e-04, 0....
#> 2 0.025  0.1 0.509137....  1.018275 2.9626, .... -2.9626,.... 0.0015, ....
#> 3 0.025  0.1 0.335043....  1.015284 3.0162, .... -3.0162,.... 0.0013, ....
#> 4 0.025  0.1 0.509227....  1.018456 2.75, 2..... -2.75, -.... 0.003, 0....
#> 5 0.025  0.1 0.365230....  1.106759 2.3977, .... -2.3977,.... 0.0082, ....
#> 6 0.025  0.1 0.555438....  1.110878 2.2414, .... -2.2414,.... 0.0125, ....
#>        lower_p power           en                               upper_name
#> 1 1e-04, 0....   0.9 1.007862.... Lan-DeMets O'Brien-Fleming approximation
#> 2 0.0015, ....   0.9 1.012586.... Lan-DeMets O'Brien-Fleming approximation
#> 3 0.0013, ....   0.9 1.010154....                        Hwang-Shih-DeCani
#> 4 0.003, 0....   0.9 1.012404....                        Hwang-Shih-DeCani
#> 5 0.0082, ....   0.9 1.088314....                        Hwang-Shih-DeCani
#> 6 0.0125, ....   0.9 1.093520....                        Hwang-Shih-DeCani
#>                                 lower_name bound_summary  final_n    max_n
#> 1 Lan-DeMets O'Brien-Fleming approximation  c("IA 1:.... 1.012053 1.012053
#> 2 Lan-DeMets O'Brien-Fleming approximation  c("IA 1:.... 1.018275 1.018275
#> 3                        Hwang-Shih-DeCani  c("IA 1:.... 1.015284 1.015284
#> 4                        Hwang-Shih-DeCani  c("IA 1:.... 1.018456 1.018456
#> 5                        Hwang-Shih-DeCani  c("IA 1:.... 1.106759 1.106759
#> 6                        Hwang-Shih-DeCani  c("IA 1:.... 1.110878 1.110878
#>   upper_z1 lower_z1
#> 1   3.7307  -3.7307
#> 2   2.9626  -2.9626
#> 3   3.0162  -3.0162
#> 4   2.7500  -2.7500
#> 5   2.3977  -2.3977
#> 6   2.2414  -2.2414
```

### Ranking and filtering

``` r
best <- job$best("final_n", direction = "min")
head(best, 10)
#>   upper_setting       timing upper_fun upper_par config_id status error_message
#> 1  function.... 0.33, 0.....    sfLDOF         0         1     ok          <NA>
#> 3  function.... 0.33, 0.....     sfHSD        -4         3     ok          <NA>
#> 2  function.... 0.5, 0.75, 1    sfLDOF         0         2     ok          <NA>
#> 4  function.... 0.5, 0.75, 1     sfHSD        -4         4     ok          <NA>
#> 5  function.... 0.33, 0.....     sfHSD         0         5     ok          <NA>
#> 6  function.... 0.5, 0.75, 1     sfHSD         0         6     ok          <NA>
#> 8  function.... 0.5, 0.75, 1     sfHSD         4         8     ok          <NA>
#> 7  function.... 0.33, 0.....     sfHSD         4         7     ok          <NA>
#>   warnings                        cache_key design_rds    call_args k test.type
#> 1     <NA> cb2610fb0a4d16425894a20d0b0d5191       <NA> 3, 2, 0..... 3         2
#> 3     <NA> a596bf2736e423e3be03e7a44ede0efa       <NA> 3, 2, 0..... 3         2
#> 2     <NA> 9a19b655ab2e76bc9718cb78cc437a7f       <NA> 3, 2, 0..... 3         2
#> 4     <NA> 1efc77f880a86f1016c08b31ff8b0e9a       <NA> 3, 2, 0..... 3         2
#> 5     <NA> d5b205647b9b1c31fa1ff28050f0bca3       <NA> 3, 2, 0..... 3         2
#> 6     <NA> 93a3a5c5b477581dbce058508a1ed2e3       <NA> 3, 2, 0..... 3         2
#> 8     <NA> 4264adbfb89d75c2370ee36cadb48789       <NA> 3, 2, 0..... 3         2
#> 7     <NA> 225b7230111b36e594173102e66f87b3       <NA> 3, 2, 0..... 3         2
#>   alpha beta          n_I final_n_I      upper_z      lower_z      upper_p
#> 1 0.025  0.1 0.333977....  1.012053 3.7307, .... -3.7307,.... 1e-04, 0....
#> 3 0.025  0.1 0.335043....  1.015284 3.0162, .... -3.0162,.... 0.0013, ....
#> 2 0.025  0.1 0.509137....  1.018275 2.9626, .... -2.9626,.... 0.0015, ....
#> 4 0.025  0.1 0.509227....  1.018456 2.75, 2..... -2.75, -.... 0.003, 0....
#> 5 0.025  0.1 0.365230....  1.106759 2.3977, .... -2.3977,.... 0.0082, ....
#> 6 0.025  0.1 0.555438....  1.110878 2.2414, .... -2.2414,.... 0.0125, ....
#> 8 0.025  0.1 0.675309....  1.350620 2.0137, .... -2.0137,.... 0.022, 0....
#> 7 0.025  0.1 0.451412....  1.367918 2.0822, .... -2.0822,.... 0.0187, ....
#>        lower_p power           en                               upper_name
#> 1 1e-04, 0....   0.9 1.007862.... Lan-DeMets O'Brien-Fleming approximation
#> 3 0.0013, ....   0.9 1.010154....                        Hwang-Shih-DeCani
#> 2 0.0015, ....   0.9 1.012586.... Lan-DeMets O'Brien-Fleming approximation
#> 4 0.003, 0....   0.9 1.012404....                        Hwang-Shih-DeCani
#> 5 0.0082, ....   0.9 1.088314....                        Hwang-Shih-DeCani
#> 6 0.0125, ....   0.9 1.093520....                        Hwang-Shih-DeCani
#> 8 0.022, 0....   0.9 1.319407....                        Hwang-Shih-DeCani
#> 7 0.0187, ....   0.9 1.329142....                        Hwang-Shih-DeCani
#>                                 lower_name bound_summary  final_n    max_n
#> 1 Lan-DeMets O'Brien-Fleming approximation  c("IA 1:.... 1.012053 1.012053
#> 3                        Hwang-Shih-DeCani  c("IA 1:.... 1.015284 1.015284
#> 2 Lan-DeMets O'Brien-Fleming approximation  c("IA 1:.... 1.018275 1.018275
#> 4                        Hwang-Shih-DeCani  c("IA 1:.... 1.018456 1.018456
#> 5                        Hwang-Shih-DeCani  c("IA 1:.... 1.106759 1.106759
#> 6                        Hwang-Shih-DeCani  c("IA 1:.... 1.110878 1.110878
#> 8                        Hwang-Shih-DeCani  c("IA 1:.... 1.350620 1.350620
#> 7                        Hwang-Shih-DeCani  c("IA 1:.... 1.367918 1.367918
#>   upper_z1 lower_z1
#> 1   3.7307  -3.7307
#> 3   3.0162  -3.0162
#> 2   2.9626  -2.9626
#> 4   2.7500  -2.7500
#> 5   2.3977  -2.3977
#> 6   2.2414  -2.2414
#> 8   2.0137  -2.0137
#> 7   2.0822  -2.0822
```

### Plot

``` r
job$plot(metric = "final_n", x = "upper_par", color = "upper_fun")
```

![](gsDesignTune_files/figure-html/unnamed-chunk-5-1.svg)

## Survival designs with `gsSurvTune()`

[`gsSurvTune()`](https://nanx.me/gsDesignTune/reference/gsSurvTune.md)
wraps
[`gsDesign::gsSurv()`](https://keaven.github.io/gsDesign/reference/nSurv.html)
for tuning time-to-event designs.

``` r
job_surv <- gsSurvTune(
  k = 3,
  test.type = 4,
  alpha = 0.025,
  beta = 0.10,
  timing = tune_values(list(c(0.33, 0.67, 1), c(0.5, 0.75, 1))),
  hr = tune_seq(0.60, 0.75, length_out = 3),
  upper = SpendingFamily$new(
    SpendingSpec$new(sfLDOF, par = tune_fixed(0)),
    SpendingSpec$new(sfHSD, par = tune_seq(-4, 4, length_out = 3))
  ),
  lower = SpendingSpec$new(sfLDOF, par = tune_fixed(0)),
  lambdaC = log(2) / 6,
  eta = 0.01,
  gamma = c(2.5, 5, 7.5, 10),
  R = c(2, 2, 2, 6),
  T = 18,
  minfup = 6,
  ratio = 1
)

job_surv$run(strategy = "grid", parallel = FALSE)
res_surv <- job_surv$results()
head(res_surv)
#>   upper_setting lower_setting       timing    hr upper_fun upper_par lower_fun
#> 1  function....  function.... 0.33, 0..... 0.600    sfLDOF         0    sfLDOF
#> 2  function....  function.... 0.33, 0..... 0.675    sfLDOF         0    sfLDOF
#> 3  function....  function.... 0.33, 0..... 0.750    sfLDOF         0    sfLDOF
#> 4  function....  function.... 0.5, 0.75, 1 0.600    sfLDOF         0    sfLDOF
#> 5  function....  function.... 0.5, 0.75, 1 0.675    sfLDOF         0    sfLDOF
#> 6  function....  function.... 0.5, 0.75, 1 0.750    sfLDOF         0    sfLDOF
#>   lower_par config_id status error_message warnings
#> 1         0         1     ok          <NA>     <NA>
#> 2         0         2     ok          <NA>     <NA>
#> 3         0         3     ok          <NA>     <NA>
#> 4         0         4     ok          <NA>     <NA>
#> 5         0         5     ok          <NA>     <NA>
#> 6         0         6     ok          <NA>     <NA>
#>                          cache_key design_rds    call_args k test.type alpha
#> 1 2bdc1d4056fd1953f381543e101e42d4       <NA> 3, 4, 0..... 3         4 0.025
#> 2 24c94ad5f8c36c3a5c6359b8095a9904       <NA> 3, 4, 0..... 3         4 0.025
#> 3 30b61e1b7463fcf57be753394c68c6f5       <NA> 3, 4, 0..... 3         4 0.025
#> 4 3dfc591107e557bdecb88c3e4ce9213b       <NA> 3, 4, 0..... 3         4 0.025
#> 5 2cd5778da64b303c943d1d4e195f9921       <NA> 3, 4, 0..... 3         4 0.025
#> 6 ff7ce872df219f3c4e206479a1aca0da       <NA> 3, 4, 0..... 3         4 0.025
#>   beta          n_I final_n_I      upper_z      lower_z      upper_p
#> 1  0.1 56.24907....  170.4517 3.7307, .... -0.719, .... 1e-04, 0....
#> 2  0.1 95.02760....  287.9624 3.7307, .... -0.719, .... 1e-04, 0....
#> 3  0.1 177.4604....  537.7591 3.7307, .... -0.719, .... 1e-04, 0....
#> 4  0.1 87.06008....  174.1202 2.9626, .... 0.3316, .... 0.0015, ....
#> 5  0.1 147.0799....  294.1598 2.9626, .... 0.3316, .... 0.0015, ....
#> 6  0.1 274.6662....  549.3326 2.9626, .... 0.3316, .... 0.0015, ....
#>        lower_p power           en                               upper_name
#> 1 0.7639, ....   0.9 108.7925.... Lan-DeMets O'Brien-Fleming approximation
#> 2 0.7639, ....   0.9 183.7948.... Lan-DeMets O'Brien-Fleming approximation
#> 3 0.7639, ....   0.9 343.2300.... Lan-DeMets O'Brien-Fleming approximation
#> 4 0.3701, ....   0.9 106.7777.... Lan-DeMets O'Brien-Fleming approximation
#> 5 0.3701, ....   0.9 180.3910.... Lan-DeMets O'Brien-Fleming approximation
#> 6 0.3701, ....   0.9 336.8735.... Lan-DeMets O'Brien-Fleming approximation
#>                                 lower_name bound_summary final_events
#> 1 Lan-DeMets O'Brien-Fleming approximation  c("IA 1:....     170.4517
#> 2 Lan-DeMets O'Brien-Fleming approximation  c("IA 1:....     287.9624
#> 3 Lan-DeMets O'Brien-Fleming approximation  c("IA 1:....     537.7591
#> 4 Lan-DeMets O'Brien-Fleming approximation  c("IA 1:....     174.1202
#> 5 Lan-DeMets O'Brien-Fleming approximation  c("IA 1:....     294.1598
#> 6 Lan-DeMets O'Brien-Fleming approximation  c("IA 1:....     549.3326
#>   max_events      n_total final_n_total analysis_time upper_z1 lower_z1
#> 1   170.4517 216, 296....           296  9.582183....   3.7307  -0.7190
#> 2   287.9624 352, 482....           482  9.554795....   3.7307  -0.7190
#> 3   537.7591 634, 874....           874  9.524268....   3.7307  -0.7190
#> 4   174.1202 284, 302....           302  11.48078....   2.9626   0.3316
#> 5   294.1598 462, 492....           492  11.45171....   2.9626   0.3316
#> 6   549.3326 834, 892....           892  11.41939....   2.9626   0.3316
```

### Calendar-timed analyses with `gsSurvCalendarTune()`

[`gsSurvCalendarTune()`](https://nanx.me/gsDesignTune/reference/gsSurvCalendarTune.md)
is similar to
[`gsSurvTune()`](https://nanx.me/gsDesignTune/reference/gsSurvTune.md),
but you specify planned calendar times of analyses via `calendarTime`
instead of information timing.

``` r
job_cal <- gsSurvCalendarTune(
  test.type = 4,
  alpha = 0.025,
  beta = 0.10,
  calendarTime = tune_values(list(c(12, 24, 36), c(9, 18, 27))),
  spending = tune_choice("information", "calendar"),
  hr = tune_seq(0.60, 0.75, length_out = 3),
  upper = SpendingFamily$new(
    SpendingSpec$new(sfLDOF, par = tune_fixed(0)),
    SpendingSpec$new(sfHSD, par = tune_seq(-4, 4, length_out = 3))
  ),
  lower = SpendingSpec$new(sfLDOF, par = tune_fixed(0)),
  lambdaC = log(2) / 6,
  eta = 0.01,
  gamma = c(2.5, 5, 7.5, 10),
  R = c(2, 2, 2, 6),
  minfup = 18,
  ratio = 1
)

job_cal$run(strategy = "grid", parallel = FALSE)
res_cal <- job_cal$results()
head(res_cal)
#>   upper_setting lower_setting calendarTime    spending    hr upper_fun
#> 1  function....  function....   12, 24, 36 information 0.600    sfLDOF
#> 2  function....  function....   12, 24, 36 information 0.675    sfLDOF
#> 3  function....  function....   12, 24, 36 information 0.750    sfLDOF
#> 4  function....  function....   12, 24, 36    calendar 0.600    sfLDOF
#> 5  function....  function....   12, 24, 36    calendar 0.675    sfLDOF
#> 6  function....  function....   12, 24, 36    calendar 0.750    sfLDOF
#>   upper_par lower_fun lower_par config_id status error_message warnings
#> 1         0    sfLDOF         0         1     ok          <NA>     <NA>
#> 2         0    sfLDOF         0         2     ok          <NA>     <NA>
#> 3         0    sfLDOF         0         3     ok          <NA>     <NA>
#> 4         0    sfLDOF         0         4     ok          <NA>     <NA>
#> 5         0    sfLDOF         0         5     ok          <NA>     <NA>
#> 6         0    sfLDOF         0         6     ok          <NA>     <NA>
#>                          cache_key design_rds    call_args k test.type alpha
#> 1 67d4ff1d6f5f24b2dbb1867dcccdedc3       <NA> 4, 0.025.... 3         4 0.025
#> 2 307ed73a6eb8e444e41038fe72f157c9       <NA> 4, 0.025.... 3         4 0.025
#> 3 b0411c34866aff5756f402c227202d2d       <NA> 4, 0.025.... 3         4 0.025
#> 4 34955b117a00dad79e8bfb1491aea92c       <NA> 4, 0.025.... 3         4 0.025
#> 5 988aef302b5b92b089bf580e7b9a3076       <NA> 4, 0.025.... 3         4 0.025
#> 6 14ba6c43ba873ead55e48552c98ec7d6       <NA> 4, 0.025.... 3         4 0.025
#>   beta       timing          n_I final_n_I      upper_z      lower_z
#> 1  0.1 0.234953.... 40.57769....  172.7049 4.4783, .... -1.5645,....
#> 2  0.1 0.239261.... 70.11500....  293.0476 4.4352, .... -1.5165,....
#> 3  0.1 0.243794.... 133.8081....  548.8561 4.3911, .... -1.467, ....
#> 4  0.1 0.234953.... 38.77264....  165.0223 3.7103, .... -1.0234,....
#> 5  0.1 0.239261.... 66.81866....  279.2704 3.7103, .... -1.0102,....
#> 6  0.1 0.243794.... 127.1924....  521.7196 3.7103, .... -0.9963,....
#>        upper_p      lower_p     power           en
#> 1 0, 0.011.... 0.9412, .... 0.8999993 132.7351....
#> 2 0, 0.012.... 0.9353, .... 0.8999992 226.1005....
#> 3 0, 0.012.... 0.9288, .... 0.8999990 424.9542....
#> 4 1e-04, 0.... 0.8469, .... 0.9000000 119.9537....
#> 5 1e-04, 0.... 0.8438, .... 0.9000000 204.1468....
#> 6 1e-04, 0.... 0.8404, .... 0.9000000 383.4974....
#>                                 upper_name
#> 1 Lan-DeMets O'Brien-Fleming approximation
#> 2 Lan-DeMets O'Brien-Fleming approximation
#> 3 Lan-DeMets O'Brien-Fleming approximation
#> 4 Lan-DeMets O'Brien-Fleming approximation
#> 5 Lan-DeMets O'Brien-Fleming approximation
#> 6 Lan-DeMets O'Brien-Fleming approximation
#>                                 lower_name bound_summary final_events
#> 1 Lan-DeMets O'Brien-Fleming approximation  c("IA 1:....     172.7049
#> 2 Lan-DeMets O'Brien-Fleming approximation  c("IA 1:....     293.0476
#> 3 Lan-DeMets O'Brien-Fleming approximation  c("IA 1:....     548.8561
#> 4 Lan-DeMets O'Brien-Fleming approximation  c("IA 1:....     165.0223
#> 5 Lan-DeMets O'Brien-Fleming approximation  c("IA 1:....     279.2704
#> 6 Lan-DeMets O'Brien-Fleming approximation  c("IA 1:....     521.7196
#>   max_events      n_total final_n_total analysis_time upper_z1 lower_z1
#> 1   172.7049 128, 212....           212    12, 24, 36   4.4783  -1.5645
#> 2   293.0476 212, 354....           354    12, 24, 36   4.4352  -1.5165
#> 3   548.8561 390, 650....           650    12, 24, 36   4.3911  -1.4670
#> 4   165.0223 122, 204....           204    12, 24, 36   3.7103  -1.0234
#> 5   279.2704 202, 336....           336    12, 24, 36   3.7103  -1.0102
#> 6   521.7196 372, 618....           618    12, 24, 36   3.7103  -0.9963
```

### Multi-scenario exploration

``` r
best_surv <- job_surv$best("final_events", direction = "min")
head(best_surv, 10)
#>    upper_setting lower_setting       timing    hr upper_fun upper_par lower_fun
#> 1   function....  function.... 0.33, 0..... 0.600    sfLDOF         0    sfLDOF
#> 7   function....  function.... 0.33, 0..... 0.600     sfHSD        -4    sfLDOF
#> 4   function....  function.... 0.5, 0.75, 1 0.600    sfLDOF         0    sfLDOF
#> 10  function....  function.... 0.5, 0.75, 1 0.600     sfHSD        -4    sfLDOF
#> 13  function....  function.... 0.33, 0..... 0.600     sfHSD         0    sfLDOF
#> 16  function....  function.... 0.5, 0.75, 1 0.600     sfHSD         0    sfLDOF
#> 22  function....  function.... 0.5, 0.75, 1 0.600     sfHSD         4    sfLDOF
#> 19  function....  function.... 0.33, 0..... 0.600     sfHSD         4    sfLDOF
#> 2   function....  function.... 0.33, 0..... 0.675    sfLDOF         0    sfLDOF
#> 8   function....  function.... 0.33, 0..... 0.675     sfHSD        -4    sfLDOF
#>    lower_par config_id status error_message warnings
#> 1          0         1     ok          <NA>     <NA>
#> 7          0         7     ok          <NA>     <NA>
#> 4          0         4     ok          <NA>     <NA>
#> 10         0        10     ok          <NA>     <NA>
#> 13         0        13     ok          <NA>     <NA>
#> 16         0        16     ok          <NA>     <NA>
#> 22         0        22     ok          <NA>     <NA>
#> 19         0        19     ok          <NA>     <NA>
#> 2          0         2     ok          <NA>     <NA>
#> 8          0         8     ok          <NA>     <NA>
#>                           cache_key design_rds    call_args k test.type alpha
#> 1  2bdc1d4056fd1953f381543e101e42d4       <NA> 3, 4, 0..... 3         4 0.025
#> 7  532c66c85af46e8d26301263fcb75f86       <NA> 3, 4, 0..... 3         4 0.025
#> 4  3dfc591107e557bdecb88c3e4ce9213b       <NA> 3, 4, 0..... 3         4 0.025
#> 10 199e919539db0b92a84028ae5045b7f1       <NA> 3, 4, 0..... 3         4 0.025
#> 13 23b47031ac3b4b8b661ab6e848699f24       <NA> 3, 4, 0..... 3         4 0.025
#> 16 49a3b99a684cf1347c4365eacc1b2300       <NA> 3, 4, 0..... 3         4 0.025
#> 22 89be71aa1ed8624d5fe1ba2470f3a62f       <NA> 3, 4, 0..... 3         4 0.025
#> 19 3ff4f5cb6365ba3f5e77131b768e977b       <NA> 3, 4, 0..... 3         4 0.025
#> 2  24c94ad5f8c36c3a5c6359b8095a9904       <NA> 3, 4, 0..... 3         4 0.025
#> 8  a6cb76c6931b049398a077d2ff067ffc       <NA> 3, 4, 0..... 3         4 0.025
#>    beta          n_I final_n_I      upper_z      lower_z      upper_p
#> 1   0.1 56.24907....  170.4517 3.7307, .... -0.719, .... 1e-04, 0....
#> 7   0.1 56.42214....  170.9762 3.0162, .... -0.7161,.... 0.0013, ....
#> 4   0.1 87.06008....  174.1202 2.9626, .... 0.3316, .... 0.0015, ....
#> 10  0.1 87.11271....  174.2254 2.75, 2..... 0.3323, .... 0.003, 0....
#> 13  0.1 61.09307....  185.1305 2.3977, .... -0.6382,.... 0.0082, ....
#> 16  0.1 93.90369....  187.8074 2.2414, .... 0.4235, .... 0.0125, ....
#> 22  0.1 111.9806....  223.9612 2.0137, .... 0.6515, .... 0.022, 0....
#> 19  0.1 74.60758....  226.0836 2.0822, .... -0.4282,.... 0.0187, ....
#> 2   0.1 95.02760....  287.9624 3.7307, .... -0.719, .... 1e-04, 0....
#> 8   0.1 95.31999....  288.8485 3.0162, .... -0.7161,.... 0.0013, ....
#>         lower_p     power           en                               upper_name
#> 1  0.7639, .... 0.9000000 108.7925.... Lan-DeMets O'Brien-Fleming approximation
#> 7  0.763, 0.... 0.9000000 108.9419....                        Hwang-Shih-DeCani
#> 4  0.3701, .... 0.9000000 106.7777.... Lan-DeMets O'Brien-Fleming approximation
#> 10 0.3698, .... 0.9000000 106.7939....                        Hwang-Shih-DeCani
#> 13 0.7383, .... 0.9000000 113.8644....                        Hwang-Shih-DeCani
#> 16 0.336, 0.... 0.9000000 111.8445....                        Hwang-Shih-DeCani
#> 22 0.2574, .... 0.9000000 126.5371....                        Hwang-Shih-DeCani
#> 19 0.6658, .... 0.8999999 128.5347....                        Hwang-Shih-DeCani
#> 2  0.7639, .... 0.9000000 183.7948.... Lan-DeMets O'Brien-Fleming approximation
#> 8  0.763, 0.... 0.9000000 184.0472....                        Hwang-Shih-DeCani
#>                                  lower_name bound_summary final_events
#> 1  Lan-DeMets O'Brien-Fleming approximation  c("IA 1:....     170.4517
#> 7  Lan-DeMets O'Brien-Fleming approximation  c("IA 1:....     170.9762
#> 4  Lan-DeMets O'Brien-Fleming approximation  c("IA 1:....     174.1202
#> 10 Lan-DeMets O'Brien-Fleming approximation  c("IA 1:....     174.2254
#> 13 Lan-DeMets O'Brien-Fleming approximation  c("IA 1:....     185.1305
#> 16 Lan-DeMets O'Brien-Fleming approximation  c("IA 1:....     187.8074
#> 22 Lan-DeMets O'Brien-Fleming approximation  c("IA 1:....     223.9612
#> 19 Lan-DeMets O'Brien-Fleming approximation  c("IA 1:....     226.0836
#> 2  Lan-DeMets O'Brien-Fleming approximation  c("IA 1:....     287.9624
#> 8  Lan-DeMets O'Brien-Fleming approximation  c("IA 1:....     288.8485
#>    max_events      n_total final_n_total analysis_time upper_z1 lower_z1
#> 1    170.4517 216, 296....           296  9.582183....   3.7307  -0.7190
#> 7    170.9762 218, 296....           296  9.582183....   3.0162  -0.7161
#> 4    174.1202 284, 302....           302  11.48078....   2.9626   0.3316
#> 10   174.2254 284, 302....           302  11.48078....   2.7500   0.3323
#> 13   185.1305 234, 320....           320  9.582183....   2.3977  -0.6382
#> 16   187.8074 306, 326....           326  11.48078....   2.2414   0.4235
#> 22   223.9612 366, 388....           388  11.48078....   2.0137   0.6515
#> 19   226.0836 286, 392....           392  9.582183....   2.0822  -0.4282
#> 2    287.9624 352, 482....           482  9.554795....   3.7307  -0.7190
#> 8    288.8485 352, 484....           484  9.554795....   3.0162  -0.7161
```

``` r
job_surv$plot(metric = "final_events", x = "hr", color = "upper_fun")
```

![](gsDesignTune_files/figure-html/unnamed-chunk-9-1.svg)

## Export a report

``` r
report_path <- tempfile(fileext = ".html")
job_surv$report(report_path)
report_path
#> [1] "/tmp/RtmpfgPNKG/file1d5f76ff28c8.html"
```
