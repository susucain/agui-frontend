import { Routes, Route, Link, useLocation } from 'react-router-dom'
import { Layout, Menu } from 'antd'
import { MessageOutlined, UploadOutlined, UnorderedListOutlined } from '@ant-design/icons'
import ChatPage from './pages/ChatPage'
import FileUpload from './pages/FileUpload'
import FileList from './pages/FileList'
import './App.css'

const { Header, Content } = Layout

const navItems = [
  // { key: '/', icon: <MessageOutlined />, label: <Link to="/">对话</Link> },
  { key: '/', icon: <UploadOutlined />, label: <Link to="/">上传文件</Link> },
  { key: '/files', icon: <UnorderedListOutlined />, label: <Link to="/files">文件列表</Link> },
]

export default function App() {
  const location = useLocation()

  return (
    <Layout style={{ minHeight: '100vh' }}>
      <Header
        style={{
          display: 'flex',
          alignItems: 'center',
          paddingInline: 24,
          position: 'sticky',
          top: 0,
          zIndex: 100,
        }}
      >
        <div style={{ color: '#fff', fontWeight: 600, fontSize: 16, marginRight: 32, whiteSpace: 'nowrap' }}>
          AGUI
        </div>
        <Menu
          theme="dark"
          mode="horizontal"
          selectedKeys={[location.pathname]}
          items={navItems}
          style={{ flex: 1, minWidth: 0 }}
        />
      </Header>
      <Content style={{ padding: 24 }}>
        <Routes>
          {/* <Route path="/" element={<ChatPage />} /> */}
          <Route path="/" element={<FileUpload />} />
          <Route path="/files" element={<FileList />} />
        </Routes>
      </Content>
    </Layout>
  )
}
