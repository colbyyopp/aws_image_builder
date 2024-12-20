output "image_recipe_arn" {
  value       = aws_imagebuilder_image_recipe.al2023.arn
}

output "image_pipeline_arn" {
  value       = aws_imagebuilder_image_pipeline.al2023.arn
}

output "image_arn" {
  value       = aws_imagebuilder_image.test.arn
}

output "al2023" {
  value = data.aws_ami.al2023.id
}