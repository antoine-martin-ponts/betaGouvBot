# encoding: utf-8
# frozen_string_literal: true

RSpec.describe BetaGouvBot::NotificationRequest do
  subject { described_class.(members, Date.today) }

  let(:members) { authors.map(&:with_indifferent_access) }

  describe 'selecting recipients of emails' do
    context 'when a member has an end date in three weeks' do
      let(:authors) { [id: 'ann', fullname: 'Ann', end: (Date.today + 21).iso8601] }

      it 'sends an email directly to the author' do
        is_expected.to include be_a_kind_of(BetaGouvBot::MailAction)
          .and(have_attributes(subject: '🗓 Fin de contrat prévue pour dans 3 semaines'))
          .and(have_attributes(recipients: ['email' => 'ann@beta.gouv.fr']))
      end
    end

    context 'when a member has an end date in two weeks' do
      let(:authors) { [id: 'ann', fullname: 'Ann', end: (Date.today + 14).iso8601] }

      it 'sends an email to the author and contact' do
        recipients = [
          { 'email' => 'ann@beta.gouv.fr' },
          { 'email' => 'contact@beta.gouv.fr' }
        ]
        is_expected.to include be_a_kind_of(BetaGouvBot::MailAction)
          .and(have_attributes(subject: '⏲ Fin de contrat prévue pour dans 2 semaines'))
          .and(have_attributes(recipients: recipients))
      end
    end
  end

  describe 'sending out emails' do
    context 'when one member has an end date in three weeks' do
      let(:authors) { [id: 'ann', fullname: 'Ann', end: (Date.today + 21).iso8601] }

      it 'sends out one email' do
        is_expected.to have(1).items
      end
    end

    context 'when two members have an end date in three weeks' do
      let(:authors) do
        [
          { id: 'ann', fullname: 'Ann', end: (Date.today + 21).iso8601 },
          { id: 'bob', fullname: 'Bob', end: (Date.today + 21).iso8601 }
        ]
      end

      it 'sends out two emails' do
        is_expected.to have(2).items
      end
    end

    context 'when two members have an end date and one of these is a non-date' do
      let(:authors) do
        [
          { id: 'ann', fullname: 'Ann', end: '2022-04-31' },
          { id: 'bob', fullname: 'Bob', end: (Date.today + 21).iso8601 }
        ]
      end

      it 'sends out one emails, ignoring invalid end dates' do
        is_expected.to have(1).items
      end
    end
  end
end
