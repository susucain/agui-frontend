import { useState } from 'react'
import { Upload, Button, Card, Typography, message, Descriptions, Space } from 'antd'
import { UploadOutlined, InboxOutlined, ArrowLeftOutlined } from '@ant-design/icons'
import { useNavigate } from 'react-router-dom'
import type { UploadProps } from 'antd'

const { Dragger } = Upload
const { Title, Link } = Typography

interface UploadResult {
  id: string
  fileName: string
  fileType: string
  url: string
  createdAt: string
}

export default function FileUpload() {
  const navigate = useNavigate()
  const [uploading, setUploading] = useState(false)
  const [result, setResult] = useState<UploadResult | null>(null)

  const customRequest: UploadProps['customRequest'] = (options) => {
    const { file, onSuccess, onError } = options

    setUploading(true)
    setResult(null)

    const formData = new FormData()
    formData.append('file', file as File)

    fetch('/oss/upload', {
      method: 'POST',
      body: formData,
    })
      .then(async (res) => {
        if (!res.ok) {
          const text = await res.text().catch(() => '')
          throw new Error(text || `HTTP ${res.status}`)
        }
        return res.json()
      })
      .then((data: UploadResult) => {
        setResult(data)
        onSuccess?.(data)
        message.success('上传成功')
      })
      .catch((err: Error) => {
        onError?.(err)
        message.error(`上传失败: ${err.message}`)
      })
      .finally(() => {
        setUploading(false)
      })
  }

  return (
    <div style={{ padding: 24 }}>
      <Card>
        <Title level={3} style={{ textAlign: 'center', marginBottom: 24 }}>
          文件上传
        </Title>

        <Dragger
          name="file"
          multiple={false}
          customRequest={customRequest}
          showUploadList={false}
          disabled={uploading}
        >
          <p className="ant-upload-drag-icon">
            <InboxOutlined />
          </p>
          <p className="ant-upload-text">点击或拖拽文件到此区域上传</p>
          <p className="ant-upload-hint">支持单文件上传</p>
        </Dragger>

        {uploading && (
          <div style={{ textAlign: 'center', marginTop: 16 }}>
            <UploadOutlined spin style={{ fontSize: 24, color: '#1677ff' }} />
            <span style={{ marginLeft: 8, color: '#1677ff' }}>正在上传...</span>
          </div>
        )}

        {result && (
          <Card
            title="上传结果"
            style={{ marginTop: 24 }}
            type="inner"
            extra={
              <Button type="primary" onClick={() => setResult(null)}>
                继续上传
              </Button>
            }
          >
            <Descriptions column={1} bordered size="small">
              <Descriptions.Item label="文件 ID">{result.id}</Descriptions.Item>
              <Descriptions.Item label="文件名">{result.fileName}</Descriptions.Item>
              <Descriptions.Item label="文件类型">{result.fileType}</Descriptions.Item>
              <Descriptions.Item label="访问链接">
                <Link href={result.url} target="_blank">
                  {result.url}
                </Link>
              </Descriptions.Item>
              <Descriptions.Item label="上传时间">{result.createdAt}</Descriptions.Item>
            </Descriptions>
          </Card>
        )}
      </Card>
    </div>
  )
}
