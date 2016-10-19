class RattleCanController < ApplicationController
	before_action :verify_current_user_present
	def all_tags
		render json: Tag.get_all
	end

	def model_tags
		logger.info params.inspect		
		tagging_ids = Tagging.where(
			taggable_type: params[:model_type],
			taggable_id:   params[:model_id].to_i
		)
		render json: Tag.find(tagging_ids.pluck(:tag_id))
	end

	def app
		@item = params[:item] # WTF
	end

	def create_tag
		taggable = taggable_from_params(params)			 
		tag = Tag.find(params[:tag_id])
		tagging = tag.attach_to(taggable, current_user) # TODO: this shouldn't create dupes. needs a test.
		
		if tagging.save
			render text: "OK"
		else
			render text: "FAIL", status: 402
		end
	end
	
	def destroy_tag
		taggable = taggable_from_params(params)	    				 
		tag = Tag.find(params[:tag_id])

		# delete ALL the tags for that taggable/tag combo... TODO FIXME REEVAL
		deletions = Tagging.where(
			taggable: taggable, 
			tag: tag
		).map{|tagging|
			tagging.destroy
		}
		
		logger.info "destroy_tag | #{params.inspect} | #{deletions.inspect} | #{current_user.inspect}"

		if deletions.all?
			render text: "OK"
		else
			render text: "FAIL", status: 402
		end
	end

	private

	def taggable_from_params(params)
		model = params[:model_type].singularize.classify.constantize
		taggable = model.find(params[:model_id].to_i)   
		taggable
	end
end
