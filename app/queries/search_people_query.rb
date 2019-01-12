# frozen_string_literal: true

class SearchPeopleQuery
  def initialize(
    collection = Person.all,
    annict_ids: nil,
    names: nil,
    order_by: nil
  )
    @collection = collection.published
    @args = {
      annict_ids: annict_ids,
      names: names,
      order_by: order_by
    }
  end

  def call
    from_arguments
  end

  private

  def from_arguments
    %i(
      annict_ids
      names
    ).each do |arg_name|
      next if @args[arg_name].nil?
      @collection = send(arg_name)
    end

    if @args[:order_by]
      direction = @args[:order_by][:direction]

      @collection = case @args[:order_by][:field]
      when "CREATED_AT"
        @collection.order(created_at: direction)
      when "FAVORITE_PEOPLE_COUNT"
        @collection.order(favorite_people_count: direction)
      end
    end

    @collection
  end

  def annict_ids
    @collection.where(id: @args[:annict_ids])
  end

  def names
    @collection.search(name_or_name_kana_cont_any: @args[:names]).result
  end
end
