RSpec.describe Schema::Key do
  describe '#key?' do
    it 'returns a key rule' do
      user = Schema::Key.new(:user, Schema::Value.new(:user))
      rule = user.key?

      expect(rule.to_ast).to eql([:key, [:user, [:predicate, [:key?, []]]]])
    end

    it 'returns a key rule & set rule created within the block' do
      user = Schema::Key.new(:user, Schema::Value.new(:user))

      rules = user.key? do |value|
        value.key(:email).required
        value.key(:age).maybe
      end

      expect(rules.to_ast).to eql([
        :and, [
          [:key, [:user, [:predicate, [:key?, []]]]],
          [:set, [
            :user, [
              [:and, [
                [:key, [:email, [:predicate, [:key?, []]]]],
                [:val, [[:user, :email], [:predicate, [:filled?, []]]]]]
              ],
              [:and, [
                [:key, [:age, [:predicate, [:key?, []]]]],
                [:or, [
                  [:val, [[:user, :age], [:predicate, [:none?, []]]]],
                  [:val, [[:user, :age], [:predicate, [:filled?, []]]]]]]]
              ]]]
          ]
        ]
      ])
    end

    it 'returns a key rule & disjunction rule created within the block' do
      user = Schema::Key.new(:user, Schema::Value.new(:account))

      rule = user.key? do |value|
        value.key(:email) { |email| email.none? | email.filled? }
      end

      expect(rule.to_ast).to eql([
        :and, [
          [:key, [:user, [:predicate, [:key?, []]]]],
          [:and, [
            [:key, [:email, [:predicate, [:key?, []]]]],
            [:or, [
              [:val, [[:account, :user, :email], [:predicate, [:none?, []]]]],
              [:val, [[:account, :user, :email], [:predicate, [:filled?, []]]]]]
            ]]
          ]
        ]
      ])
    end
  end
end
