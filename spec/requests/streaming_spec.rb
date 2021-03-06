require "spec_helper"

describe "Streaming Requests", streaming: true do
  with_format(:json) do
    describe "GET /room/:room_id/live" do
      let!(:room) { create(:room) }

      context "when authenticated" do
        let!(:user) { create(:user) }

        before do
          authenticate(user.api_auth_token)
        end

        it "streams incoming messages in real time" do
          stream "/room/#{room.id}/live" do |chunks|
            message = nil

            expect {
              message = create(:text_message, room: room)
              sleep 1 # Wait for stream
            }.to change {
              chunks.size
            }.from(0).to(1)

            expect(chunks.last).to eq(
              "body" => message.body,
              "created_at" => message.created_at,
              "id" => message.id,
              "room_id" => message.room_id,
              "starred" => message.starred?,
              "type" => message.type,
              "user_id" => message.user_id
            )

            expect {
              message = create(:paste_message, room: room)
              sleep 1 # Wait for stream
            }.to change {
              chunks.size
            }.from(1).to(2)

            expect(chunks.last).to eq(
              "body" => message.body,
              "created_at" => message.created_at,
              "id" => message.id,
              "room_id" => message.room_id,
              "starred" => message.starred?,
              "type" => message.type,
              "user_id" => message.user_id
            )

            expect {
              create(:text_message)
              sleep 1 # Wait for stream
            }.not_to change {
              chunks.size
            }
          end

          expect(response.status).to eq(200)
        end

        it "shows expanded sound messages" do
          stream "/room/#{room.id}/live" do |chunks|
            message = nil

            expect {
              message = create(:sound_message, room: room)
              sleep 1 # Wait for stream
            }.to change {
              chunks.size
            }.from(0).to(1)

            expect(chunks.last).to eq(
              "body" => message.body,
              "created_at" => message.created_at,
              "description" => message.description,
              "id" => message.id,
              "room_id" => message.room_id,
              "starred" => message.starred?,
              "type" => message.type,
              "url" => message.url,
              "user_id" => message.user_id
            )
          end

          expect(response.status).to eq(200)
        end

        it "shows expanded tweet messages" do
          stream "/room/#{room.id}/live" do |chunks|
            message = nil

            expect {
              message = create(:tweet_message, room: room)
              sleep 1 # Wait for stream
            }.to change {
              chunks.size
            }.from(0).to(1)

            expect(chunks.last).to eq(
              "body" => message.body,
              "created_at" => message.created_at,
              "id" => message.id,
              "room_id" => message.room_id,
              "starred" => message.starred?,
              "tweet" => message.metadata,
              "type" => message.type,
              "user_id" => message.user_id
            )
          end

          expect(response.status).to eq(200)
        end
      end

      context "when unauthenticated" do
        it "requires authentication" do
          stream "/room/#{room.id}/live" do |chunks|
            expect {
              create(:text_message, room: room)
              sleep 1 # Wait for stream
            }.not_to change {
              chunks.size
            }
          end

          expect(response.status).to eq(401)
        end
      end
    end
  end
end
