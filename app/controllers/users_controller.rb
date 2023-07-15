class UsersController < ApplicationController
    skip_before_action :verify_authenticity_token, only: [:index]

    def index 
        users = User.all
        render js: users
    end

    def create
        user = User.create(user_params)
        if user.valid?
          render json: user, status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end
    
      private
    
      def user_params
        params.permit(:profile_url, :username, :password, :password_confirmation)
      end
end
