# Configuración de la Tabla Users en Supabase

## ⚠️ IMPORTANTE: Configuración de tu Tabla Actual

Tu tabla `users` tiene los siguientes campos:
- `first_name`
- `last_name`
- `email`
- `password_hash`
- `status`
- `created_at`
- `updated_at`

## 🔧 Configuración Necesaria en Supabase

### 1. Configurar Valores por Defecto

Para que la inserción funcione correctamente, necesitas configurar valores por defecto en tu tabla. Ve a **Table Editor** > **users** y configura:

#### Campo `created_at`:
- Tipo: `timestamp with time zone`
- Valor por defecto: `now()`

#### Campo `updated_at`:
- Tipo: `timestamp with time zone`
- Valor por defecto: `now()`

#### Campo `status`:
- Tipo: `text`
- Valor por defecto: `'active'`

#### Campo `password_hash`:
- Tipo: `text`
- **Permitir NULL**: ✅ (marcado)
- Nota: No guardamos el password_hash aquí porque Supabase Auth ya lo maneja de forma segura

### 2. Configurar Row Level Security (RLS)

Ejecuta este script en el **SQL Editor** de Supabase:

```sql
-- Habilitar Row Level Security en la tabla users
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Política: Permitir INSERT para usuarios autenticados
-- Esto permite que cuando un usuario se registre, pueda insertar su propio registro
CREATE POLICY "Users can insert their own data"
  ON public.users
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Política: Los usuarios pueden ver solo su propia información
CREATE POLICY "Users can view their own data"
  ON public.users
  FOR SELECT
  TO authenticated
  USING (email = auth.jwt()->>'email');

-- Política: Los usuarios pueden actualizar solo su propia información
CREATE POLICY "Users can update their own data"
  ON public.users
  FOR UPDATE
  TO authenticated
  USING (email = auth.jwt()->>'email')
  WITH CHECK (email = auth.jwt()->>'email');

-- Trigger para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplicar el trigger a la tabla users
DROP TRIGGER IF EXISTS update_users_updated_at ON public.users;
CREATE TRIGGER update_users_updated_at
  BEFORE UPDATE ON public.users
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();
```

### 3. Estructura Completa de la Tabla

Si necesitas recrear la tabla desde cero, usa este script:

```sql
-- Eliminar tabla existente (¡CUIDADO! Esto borra todos los datos)
-- DROP TABLE IF EXISTS public.users CASCADE;

-- Crear tabla users
CREATE TABLE IF NOT EXISTS public.users (
  id BIGSERIAL PRIMARY KEY,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT, -- NULL porque Supabase Auth maneja las contraseñas
  status TEXT DEFAULT 'active',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Crear índice en email para búsquedas rápidas
CREATE INDEX IF NOT EXISTS users_email_idx ON public.users(email);

-- Habilitar RLS
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
```

## 🔄 Cómo Funciona la Integración

### Flujo de Registro:

1. **Usuario completa el formulario** de registro
2. **Validación de contraseña** con el indicador de fortaleza
3. **Verificación de email duplicado** antes de crear la cuenta
4. **Supabase Auth crea el usuario** en `auth.users` (con password_hash seguro)
5. **La app inserta los datos** en tu tabla `users`:
   ```dart
   await supabase.from('users').insert({
     'first_name': 'Juan',
     'last_name': 'Pérez',
     'email': 'juan@example.com',
     'status': 'active',
   });
   ```
6. **Campos automáticos**:
   - `created_at`: Se llena automáticamente con la fecha actual
   - `updated_at`: Se llena automáticamente con la fecha actual
   - `password_hash`: Se deja NULL (Supabase Auth lo maneja)

### Flujo de Login:

1. **Usuario ingresa credenciales**
2. **Supabase Auth valida** contra `auth.users`
3. **La app puede consultar** datos adicionales de `users`:
   ```dart
   final userData = await supabase
     .from('users')
     .select()
     .eq('email', userEmail)
     .single();
   ```

## 📊 Verificar que Funciona

### 1. Después de Registrar un Usuario

Ve a **Table Editor** > **users** y deberías ver:

| id | first_name | last_name | email | password_hash | status | created_at | updated_at |
|----|------------|-----------|-------|---------------|--------|------------|------------|
| 1 | Juan | Pérez | juan@example.com | NULL | active | 2026-01-15... | 2026-01-15... |

### 2. Consulta SQL para Verificar

```sql
SELECT 
  u.id,
  u.first_name,
  u.last_name,
  u.email,
  u.status,
  u.created_at,
  a.email_confirmed_at,
  a.last_sign_in_at
FROM public.users u
LEFT JOIN auth.users a ON u.email = a.email
ORDER BY u.created_at DESC;
```

Esto te mostrará los usuarios en tu tabla junto con información de autenticación.

## ❓ Preguntas Frecuentes

### ¿Por qué password_hash es NULL?

Supabase Auth ya maneja las contraseñas de forma segura en `auth.users`. No necesitas (ni debes) guardar el hash de la contraseña en tu tabla personalizada. Esto es más seguro porque:
- Supabase usa algoritmos de hashing robustos
- Las contraseñas están aisladas en una tabla del sistema
- Reduces el riesgo de exposición de datos sensibles

### ¿Cómo actualizo el status de un usuario?

```dart
await supabase
  .from('users')
  .update({'status': 'inactive'})
  .eq('email', userEmail);
```

### ¿Puedo agregar más campos?

Sí, puedes agregar campos como:
- `phone_number`
- `avatar_url`
- `birth_date`
- `address`
- etc.

Solo asegúrate de actualizar el código de inserción en `register_screen.dart`.

## 🚨 Troubleshooting

### Error: "new row violates row-level security policy"

**Solución**: Verifica que las políticas RLS estén configuradas correctamente. Ejecuta el script SQL de la sección 2.

### Error: "duplicate key value violates unique constraint"

**Solución**: El email ya existe en la tabla. Esto no debería pasar porque ya verificamos duplicados antes de registrar.

### Los campos created_at/updated_at están vacíos

**Solución**: Configura los valores por defecto en la tabla como se indica en la sección 1.

### Error: "permission denied for table users"

**Solución**: Verifica que RLS esté habilitado y las políticas estén creadas correctamente.
