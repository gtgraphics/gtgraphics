namespace :lists do
  desc 'Refreshes all list positions'
  task rearrange: %w(lists:rearrange:project_images
                     lists:rearrange:image_styles
                     lists:rearrange:user_social_links)

  namespace :rearrange do
    desc 'Refreshes list positions of Project::Images'
    task project_images: :environment do
      Project.transaction do
        Project.includes(:project_images).find_each do |project|
          project.project_images.sort_by(&:position).each_with_index do |pi, idx|
            pi.update_column(:position, idx.next)
          end
        end
      end
      puts 'Fixes Project::Image positions'
    end

    desc 'Refreshes list positions of Image::Styles'
    task image_styles: :environment do
      Image.includes(:styles).find_each do |image|
        image.styles.sort_by(&:position).each_with_index do |style, index|
          style.update_column(:position, index.next)
        end
      end
      puts 'Fixes Image::Style positions'
    end

    desc 'Refreshes list positions of User::SocialLinks'
    task user_social_links: :environment do
      User.includes(:social_links).find_each do |user|
        user.social_links.sort_by(&:position).each_with_index do |sl, index|
          sl.update_column(:position, index.next)
        end
      end
      puts 'Fixes User::SocialLink positions'
    end
  end
end
