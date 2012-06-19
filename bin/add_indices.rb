require 'mongo'

require_relative '../lib/tobias-random/config'

$dois = TobiasRandom::Config.dois

$dois.ensure_index [[:random_index, 1], ['published.year', 1]]
$dois.ensure_index [[:random_index, 1], [:type, 1], ['published.year', 1]]
$dois.ensure_index [[:random_index, 1], [:type, 1], ['journal.issn', 1], ['published.year', 1]]
$dois.ensure_index [[:random_index, 1], [:type, 1], ['journal.full_title', 1], ['published.year', 1]]
