require 'rails_helper'
RSpec.describe Loggable do
  class DummyClass
    include Loggable
  end
  let(:loggable_instance) { DummyClass.new }

  describe '#log_override' do
    let(:override_counter) { 0 }
    let(:override_log) { [] }
    let(:invalid_players) do
      invalid_players = []
      (1..3).each do |num|
        invalid_players << {
          player_id: num,
          position: '1B',
          reason: Faker::ChuckNorris.fact
        }
      end
      invalid_players
    end

    context 'when a log is added' do
      it 'adds the log and increments the counter' do
        counter_result = loggable_instance.log_override(invalid_players, override_log, override_counter)
        expect(counter_result).to eq 1
      end
    end
  end

  describe '#write_overrides_to_log' do
    let(:override_counter) { 0 }
    let(:override_log) { [ 'hi from log 1', 'hi from log 2' ] }
    let(:file_path) { 'test_teeball_log.txt' }

    context 'when the text file doesn\'t exist' do
      after do
        File.delete(file_path) if File.exist?(file_path)
      end

      let(:override_log) { [] }
      it 'creates it using `open`' do
        loggable_instance.write_overrides_to_log(override_counter, override_log, file_path)
        expect(File.exist?(file_path)).to be true
      end

      it 'does not include the time or override counter in the file' do
        loggable_instance.write_overrides_to_log(override_counter, override_log, file_path)

        expect(File.exist?(file_path)).to be true
        expect(File.size(file_path)).to eq(0)
      end
    end

    context 'when there are logs in the override log' do
      after do
        File.delete(file_path) if File.exist?(file_path)
      end

      it 'saves them to the file_path.txt' do
        loggable_instance.write_overrides_to_log(override_counter, override_log, file_path)

        expect(File.exist?(file_path)).to be true
        expect(File.size(file_path)).not_to eq (0)
      end
    end
  end
end
