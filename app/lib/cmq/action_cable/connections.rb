module Cmq
  module ActionCable
    class Connections
      def self.connected_enrollments_for_room(room)
        Kredis.hash(room, typed: :integer).keys
      end

      def self.add_enrollment_to_room(room, enrollment_id)
        hash = Kredis.hash(room, typed: :integer)
        hash[enrollment_id] = 0 if hash[enrollment_id].nil?
        hash[enrollment_id] += 1
      end

      def self.remove_enrollment_from_room(room, enrollment_id)
        hash = Kredis.hash(room, typed: :integer)
        hash[enrollment_id] = 0 if hash[enrollment_id].nil?
        hash[enrollment_id] -= 1

        if hash[enrollment_id] <= 0
          hash.delete(enrollment_id)
        end
      end
    end
  end
end
