class RosterInvitesController < ApplicationController
	def new 
		@roster_invite = RosterInvite.new
	end

	def create
		@team = Team.find params[:roster_invite][:team_id]
		@roster_invite = RosterInvite.new invite_params
		@roster_invite.sender_id = current_user.id
		@team_roster = TeamRoster.find params[:roster_invite][:team_roster_id]
		@roster_invite.team_roster_id = @team_roster.id
		@roster_invite.email = @roster_invite.email.downcase

		if @roster_invite.save
			if @roster_invite.recipient != nil
				roster = Roster.where("team_roster_id = ? AND user_id = ?", @team_roster.id, @roster_invite.recipient.id)
				#RosterInviteMailer.existing_user_invite(@roster_invite).deliver
				if roster.empty? == true
					@roster_invite.recipient.team_rosters.push(@roster_invite.team_roster)
					if @roster_invite.captain?
						roster.first.captain = true
						roster.first.save
					end
					redirect_to team_team_roster_path(@team, @team_roster)
					flash[:notice] = "Player added"
				else
					redirect_to team_team_roster_path(@team, @team_roster)
					flash[:alert] = "Player has already been added to the team"
				end
			else
				#RosterInviteMailer.new_user_invite(@roster_invite, new_user_registration_path(:invite_token => @roster_invite.token)).deliver
				redirect_to team_team_roster_path(@team, @team_roster)
				flash[:notice] = "Email sent to user"
			end
		else
			redirect_to team_team_roster_path(@team, @team_roster)
			flash[:alert] = "Player could not be added"
		end
	end	

	private

		def invite_params
			params.require(:roster_invite).permit(:email, :captain)
		end
end
