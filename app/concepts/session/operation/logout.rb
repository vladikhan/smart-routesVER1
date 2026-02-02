module Session::Operation
  class Logout < Trailblazer::Operation
    step :handle_logout!

    def handle_logout!(ctx, controller:, **)
      controller.sign_out
    end
  end
end