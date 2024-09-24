variable "cluster_name" {
  description = "EKS 클러스터 이름"
  type        = string
}

variable "node_group_name" {
  description = "EKS 노드 그룹 이름"
  type        = string
}

variable "subnet_ids" {
  description = "EKS 클러스터에 사용할 서브넷 ID 리스트"
  type        = list(string)
}

variable "ami_id" {
  description = "워크노드에 사용할 AMI ID"
  type        = string
}

variable "instance_profile_name" {
  description = "워크노드에 사용할 인스턴스 프로파일 이름"
  type        = string
}

variable "desired_size" {
  description = "워크노드의 원하는 크기"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "워크노드의 최대 크기"
  type        = number
  default     = 4
}

variable "min_size" {
  description = "워크노드의 최소 크기"
  type        = number
  default     = 1
}

variable "volume_size" {
  description = "워크노드의 볼륨 크기"
  type        = number
  default     = 20
}
