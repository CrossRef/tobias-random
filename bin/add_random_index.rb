require 'mongo'

require_relative '../lib/tobias-random/config'

$dois = TobiasRandom::Config.dois

$selector = {
  'random_index' => {'$exists' => false}
}

$query_options = {
  :limit => 20000
}

$finished = false
$last_count = -1

$dois.ensure_index [['random_index', 1]]

until $last_count.zero? do
  $last_count = 0
  $dois.find($selector, $query_options) do |cursor|
    cursor.each do |doc|
      doc[:random_index] = rand
      $dois.save doc
      $last_count += 1
    end

    puts "Added #{$last_count}"
  end
end
