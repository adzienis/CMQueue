module Cmq
  module ActionCable
    class Connections
      def self.connected_enrollments_for_room(room)
        Kredis.set(room, typed: :integer)
      end

      def self.add_enrollment_to_room(room, enrollment_id)
        Kredis.set(room, typed: :integer) << enrollment_id
      end

      def self.remove_enrollment_from_room(room, enrollment_id)
        Kredis.set(room, typed: :integer).remove(enrollment_id)
      end
    end
  end
end
