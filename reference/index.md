# Package index

## Tune jobs

Create a tune job

- [`gsDesignTune()`](https://nanx.me/gsDesignTune/reference/gsDesignTune.md)
  :

  Create a tune job for
  [`gsDesign::gsDesign()`](https://keaven.github.io/gsDesign/reference/gsDesign.html)

- [`gsSurvTune()`](https://nanx.me/gsDesignTune/reference/gsSurvTune.md)
  :

  Create a tune job for
  [`gsDesign::gsSurv()`](https://keaven.github.io/gsDesign/reference/nSurv.html)

- [`gsSurvCalendarTune()`](https://nanx.me/gsDesignTune/reference/gsSurvCalendarTune.md)
  :

  Create a tune job for
  [`gsDesign::gsSurvCalendar()`](https://keaven.github.io/gsDesign/reference/gsSurvCalendar.html)

## Tune job workflow

R6 class for running searches, collecting results, and exploring designs

- [`GSDTuneJob`](https://nanx.me/gsDesignTune/reference/GSDTuneJob.md) :
  GSDTuneJob

## Spending function tuning

User-friendly specifications for spending functions and their parameters

- [`spending_specs`](https://nanx.me/gsDesignTune/reference/spending_specs.md)
  : Spending function specifications
- [`SpendingSpec`](https://nanx.me/gsDesignTune/reference/SpendingSpec.md)
  : SpendingSpec
- [`SpendingFamily`](https://nanx.me/gsDesignTune/reference/SpendingFamily.md)
  : SpendingFamily

## Tune specifications

Define candidate sets and dependencies for arguments to be explored

- [`tune_specs`](https://nanx.me/gsDesignTune/reference/tune_specs.md) :
  Tune specifications
- [`tune_fixed()`](https://nanx.me/gsDesignTune/reference/tune_fixed.md)
  : Fixed (non-tuned) value
- [`tune_values()`](https://nanx.me/gsDesignTune/reference/tune_values.md)
  : Explicit candidate values
- [`tune_seq()`](https://nanx.me/gsDesignTune/reference/tune_seq.md) :
  Numeric sequence candidates
- [`tune_int()`](https://nanx.me/gsDesignTune/reference/tune_int.md) :
  Integer sequence candidates
- [`tune_choice()`](https://nanx.me/gsDesignTune/reference/tune_choice.md)
  : Categorical choices
- [`tune_dep()`](https://nanx.me/gsDesignTune/reference/tune_dep.md) :
  Dependent tuning specification

## Utilities

- [`toString(`*`<function>`*`)`](https://nanx.me/gsDesignTune/reference/toString.function.md)
  : Convert a function to a short label string
