#!/bin/sh

pandoc -V geometry:paperwidth=210mm -V geometry:paperheight=297mm -V geometry:margin=2cm felles-tjenestebeskrivelse.md -s -o felles-tjenestebeskrivelse.pdf
