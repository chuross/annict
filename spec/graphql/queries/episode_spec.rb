# frozen_string_literal: true

describe "GraphQL API Query" do
  describe "episode" do
    let!(:episode) { create(:episode) }

    context "when `annict_id` argument is specified" do
      let(:result) do
        query_string = <<~QUERY
          query {
            episode(annictId: #{episode.id}) {
              annictId
              title
            }
          }
        QUERY

        res = AnnictSchema.execute(query_string)
        pp(res) if res["errors"]
        res
      end

      it "shows episode" do
        expect(result.dig("data", "episode")).to eq(
          "annictId" => episode.id,
          "title" => episode.title
        )
      end
    end

    context "`records` field" do
      let!(:record1) { create(:episode_record, episode: episode) }
      let!(:record2) { create(:episode_record, episode: episode) }
      let!(:result) do
        query_string = <<~QUERY
          query {
            episode(annictId: #{episode.id}) {
              annictId
              records(orderBy: { field: CREATED_AT, direction: ASC }) {
                edges {
                  node {
                    annictId
                    comment
                  }
                }
              }
            }
          }
        QUERY

        res = AnnictSchema.execute(query_string)
        pp(res) if res["errors"]
        res
      end

      it "shows episode's records" do
        expect(result.dig("data", "episode")).to eq(
          "annictId" => episode.id,
          "records" => {
            "edges" => [
              {
                "node" => {
                  "annictId" => record1.id,
                  "comment" => record1.comment
                }
              },
              {
                "node" => {
                  "annictId" => record2.id,
                  "comment" => record2.comment
                }
              }
            ]
          }
        )
      end
    end
  end
end
