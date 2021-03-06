require 'rails_helper'

RSpec.describe FindSornsJob, type: :job do
  describe "#perform_later" do
    ActiveJob::Base.queue_adapter = :test

    context "enqueuing for later" do
      it "Enqueues a job" do
        expect {
          FindSornsJob.perform_later
        }.to have_enqueued_job
      end
    end

    context "while performing" do
      it "calls .find_sorns" do
        mock_client = double(FederalRegisterClient)
        expect(FederalRegisterClient).to receive(:new).and_return mock_client
        expect(mock_client).to receive(:find_sorns)

        FindSornsJob.perform_now
      end
    end
  end
end
