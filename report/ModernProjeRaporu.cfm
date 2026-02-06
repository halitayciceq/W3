<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>🚀 Modern Proje Raporu</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script defer src="https://cdn.jsdelivr.net/npm/alpinejs@3.12.0/dist/cdn.min.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>

<body class="bg-gray-50 font-sans">
    <!-- Header -->
    <div class="bg-white shadow-sm border-b">
        <div class="max-w-7xl mx-auto px-4 py-4">
            <div class="flex items-center justify-between">
                <div class="flex items-center space-x-4">
                    <div class="bg-blue-500 p-3 rounded-lg">
                        <i class="fas fa-project-diagram text-white text-xl"></i>
                    </div>
                    <div>
                        <h1 class="text-2xl font-bold text-gray-900">Proje & Operasyon İzleme</h1>
                        <p class="text-gray-600">Modern Dashboard</p>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Main App -->
    <div x-data="projectApp()" x-init="init()" class="max-w-7xl mx-auto px-4 py-6">
        
        <!-- Stats Cards -->
        <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
            <div class="bg-white rounded-lg p-6 shadow">
                <div class="flex items-center">
                    <div class="flex-1">
                        <p class="text-sm font-medium text-gray-600">Toplam Proje</p>
                        <p class="text-2xl font-bold text-gray-900" x-text="stats.total">0</p>
                    </div>
                    <i class="fas fa-folder-open text-blue-500 text-2xl"></i>
                </div>
            </div>
            <div class="bg-white rounded-lg p-6 shadow">
                <div class="flex items-center">
                    <div class="flex-1">
                        <p class="text-sm font-medium text-gray-600">Aktif</p>
                        <p class="text-2xl font-bold text-green-600" x-text="stats.active">0</p>
                    </div>
                    <i class="fas fa-play-circle text-green-500 text-2xl"></i>
                </div>
            </div>
            <div class="bg-white rounded-lg p-6 shadow">
                <div class="flex items-center">
                    <div class="flex-1">
                        <p class="text-sm font-medium text-gray-600">Geciken</p>
                        <p class="text-2xl font-bold text-red-600" x-text="stats.delayed">0</p>
                    </div>
                    <i class="fas fa-exclamation-triangle text-red-500 text-2xl"></i>
                </div>
            </div>
            <div class="bg-white rounded-lg p-6 shadow">
                <div class="flex items-center">
                    <div class="flex-1">
                        <p class="text-sm font-medium text-gray-600">Tamamlanan</p>
                        <p class="text-2xl font-bold text-blue-600" x-text="stats.completed">0</p>
                    </div>
                    <i class="fas fa-check-circle text-blue-500 text-2xl"></i>
                </div>
            </div>
        </div>

        <!-- Filters -->
        <div class="bg-white rounded-lg shadow p-6 mb-8">
            <div class="flex flex-wrap gap-4">
                <input 
                    type="text" 
                    x-model="searchQuery"
                    @input.debounce.300ms="searchProjects()"
                    placeholder="Proje ara..."
                    class="flex-1 min-w-64 px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent">
                
                <select x-model="filterStatus" @change="filterProjects()" class="px-4 py-2 border border-gray-300 rounded-lg">
                    <option value="">Tüm Durumlar</option>
                    <option value="active">Aktif</option>
                    <option value="completed">Tamamlandı</option>
                    <option value="delayed">Geciken</option>
                </select>

                <button @click="exportExcel()" class="bg-green-500 hover:bg-green-600 text-white px-4 py-2 rounded-lg">
                    <i class="fas fa-download mr-2"></i>Excel
                </button>
            </div>
        </div>

        <!-- Projects Grid -->
        <div class="space-y-4">
            <div x-show="loading" class="text-center py-8">
                <i class="fas fa-spinner fa-spin text-2xl text-blue-500"></i>
                <p class="mt-2 text-gray-600">Yükleniyor...</p>
            </div>

            <template x-for="project in projects" :key="project.id">
                <div class="bg-white rounded-lg shadow p-6">
                    <div class="flex items-center justify-between">
                        <div class="flex items-center space-x-4">
                            <div class="w-12 h-12 bg-blue-500 rounded-lg flex items-center justify-center text-white font-bold">
                                <span x-text="project.number"></span>
                            </div>
                            <div>
                                <h3 class="text-lg font-semibold" x-text="project.name"></h3>
                                <p class="text-gray-600" x-text="project.responsible"></p>
                            </div>
                        </div>
                        
                        <div class="flex items-center space-x-4">
                            <div class="text-center">
                                <div class="text-2xl font-bold" x-text="project.completion + '%'"></div>
                                <div class="text-sm text-gray-500">Tamamlanma</div>
                            </div>
                            <span 
                                class="px-3 py-1 rounded-full text-sm font-medium"
                                :class="{
                                    'bg-green-100 text-green-800': project.status === 'completed',
                                    'bg-blue-100 text-blue-800': project.status === 'active',
                                    'bg-red-100 text-red-800': project.status === 'delayed'
                                }"
                                x-text="getStatusText(project.status)">
                            </span>
                        </div>
                    </div>
                </div>
            </template>
        </div>
    </div>

    <script>
        function projectApp() {
            return {
                loading: true,
                searchQuery: '',
                filterStatus: '',
                projects: [],
                stats: { total: 0, active: 0, delayed: 0, completed: 0 },

                async init() {
                    await this.loadData();
                    this.loading = false;
                },

                async loadData() {
                    // Mock data for demo
                    this.projects = [
                        { id: 1, number: 'PR001', name: 'ERP Web Arayüzü', responsible: 'Ahmet Y.', completion: 75, status: 'active' },
                        { id: 2, number: 'PR002', name: 'Mobil CRM', responsible: 'Ayşe D.', completion: 100, status: 'completed' },
                        { id: 3, number: 'PR003', name: 'API Gateway', responsible: 'Mehmet K.', completion: 45, status: 'delayed' }
                    ];
                    
                    this.stats = { total: 3, active: 1, delayed: 1, completed: 1 };
                },

                searchProjects() {
                    // Search logic
                },

                filterProjects() {
                    // Filter logic  
                },

                exportExcel() {
                    alert('Excel export özelliği yakında!');
                },

                getStatusText(status) {
                    const map = { active: 'Aktif', completed: 'Tamamlandı', delayed: 'Geciken' };
                    return map[status] || status;
                }
            }
        }
    </script>
</body>
</html>
