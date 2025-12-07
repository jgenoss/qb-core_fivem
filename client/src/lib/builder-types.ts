export type ElementType = 'container' | 'text' | 'button' | 'input' | 'image' | 'card' | 'grid';

export interface UIElement {
  id: string;
  type: ElementType;
  name: string;
  props: {
    // Content props
    content?: string;
    tag?: string;
    label?: string;
    src?: string;
    placeholder?: string;
    
    // Vue/Logic props
    vModel?: string;
    vIf?: string;
    vFor?: string;
    ref?: string;
    
    // Event handlers
    onClick?: string; // function name or expression
    onChange?: string;
    
    [key: string]: any;
  };
  styles?: Record<string, string>;
  children?: UIElement[];
}

export interface GlobalStyles {
  primaryColor: string;
  fontFamily: string;
  borderRadius: string;
  baseFontSize: string;
}

export const defaultGlobalStyles: GlobalStyles = {
  primaryColor: '217 91% 60%', // HSL format without hsl()
  fontFamily: 'Inter, sans-serif',
  borderRadius: '0.5rem',
  baseFontSize: '16px'
};

export const initialElements: UIElement[] = [
  {
    id: 'root',
    type: 'container',
    name: 'App Container',
    props: {
        id: 'app'
    },
    styles: {
      padding: '2rem',
      display: 'flex',
      flexDirection: 'column',
      gap: '1rem',
      maxWidth: '1000px',
      margin: '0 auto',
      minHeight: '100vh',
    },
    children: [
      {
        id: 'header-1',
        type: 'text',
        name: 'Main Heading',
        props: {
          content: 'Dashboard Overview',
          tag: 'h1',
        },
        styles: {
          fontSize: '2.5rem',
          fontWeight: 'bold',
          color: 'hsl(var(--foreground))',
          marginBottom: '1rem',
          letterSpacing: '-0.02em'
        }
      },
      {
        id: 'grid-1',
        type: 'container',
        name: 'Stats Grid',
        props: {},
        styles: {
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fit, minmax(250px, 1fr))',
            gap: '1rem',
            width: '100%'
        },
        children: [
             {
            id: 'card-1',
            type: 'card',
            name: 'Stat Card 1',
            props: {},
            styles: {
              backgroundColor: 'hsl(var(--card))',
              padding: '1.5rem',
              borderRadius: 'var(--radius)',
              border: '1px solid hsl(var(--border))',
              display: 'flex',
              flexDirection: 'column',
              gap: '0.5rem'
            },
            children: [
               {
                id: 'text-2',
                type: 'text',
                name: 'Label',
                props: {
                  content: 'Total Revenue',
                  tag: 'h3',
                },
                styles: {
                  fontSize: '0.875rem',
                  fontWeight: '500',
                  color: 'hsl(var(--muted-foreground))',
                }
              },
              {
                id: 'text-3',
                type: 'text',
                name: 'Value',
                props: {
                  content: '$45,231.89',
                  tag: 'div',
                },
                styles: {
                  fontSize: '2rem',
                  fontWeight: '700',
                  color: 'hsl(var(--foreground))',
                }
              }
            ]
          },
          {
            id: 'card-2',
            type: 'card',
            name: 'Stat Card 2',
            props: {},
            styles: {
              backgroundColor: 'hsl(var(--card))',
              padding: '1.5rem',
              borderRadius: 'var(--radius)',
              border: '1px solid hsl(var(--border))',
              display: 'flex',
              flexDirection: 'column',
              gap: '0.5rem'
            },
            children: [
               {
                id: 'text-2-2',
                type: 'text',
                name: 'Label',
                props: {
                  content: 'Active Users',
                  tag: 'h3',
                },
                styles: {
                  fontSize: '0.875rem',
                  fontWeight: '500',
                  color: 'hsl(var(--muted-foreground))',
                }
              },
              {
                id: 'text-3-2',
                type: 'text',
                name: 'Value',
                props: {
                  content: '+2,350',
                  tag: 'div',
                },
                styles: {
                  fontSize: '2rem',
                  fontWeight: '700',
                  color: 'hsl(var(--chart-2))',
                }
              }
            ]
          }
        ]
      }
    ]
  }
];

export const prebuiltBlocks: Record<string, UIElement> = {
  'hero': {
    id: 'hero',
    type: 'container',
    name: 'Hero Section',
    props: {},
    styles: {
      padding: '4rem 2rem',
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      textAlign: 'center',
      gap: '1.5rem',
      backgroundColor: 'hsl(var(--muted)/0.3)',
      borderRadius: 'var(--radius)',
      margin: '2rem 0'
    },
    children: [
      {
        id: 'hero-title',
        type: 'text',
        name: 'Hero Title',
        props: { tag: 'h1', content: 'Build Faster' },
        styles: { fontSize: '3.5rem', fontWeight: '800', lineHeight: '1.2' }
      },
      {
        id: 'hero-desc',
        type: 'text',
        name: 'Hero Description',
        props: { tag: 'p', content: 'Create beautiful interfaces in minutes with our drag-and-drop builder.' },
        styles: { fontSize: '1.25rem', color: 'hsl(var(--muted-foreground))', maxWidth: '600px' }
      },
      {
        id: 'hero-cta',
        type: 'button',
        name: 'CTA Button',
        props: { label: 'Get Started' },
        styles: { 
            padding: '0.75rem 1.5rem', 
            backgroundColor: 'hsl(var(--primary))', 
            color: 'white', 
            borderRadius: 'var(--radius)', 
            fontWeight: '600',
            border: 'none',
            marginTop: '1rem'
        }
      }
    ]
  },
  'navbar': {
    id: 'navbar',
    type: 'container',
    name: 'Navbar',
    props: {},
    styles: {
      display: 'flex',
      justifyContent: 'space-between',
      alignItems: 'center',
      padding: '1rem 2rem',
      borderBottom: '1px solid hsl(var(--border))',
      width: '100%',
      backgroundColor: 'hsl(var(--background))'
    },
    children: [
      {
        id: 'nav-logo',
        type: 'text',
        name: 'Logo',
        props: { tag: 'h3', content: 'Brand' },
        styles: { fontSize: '1.5rem', fontWeight: 'bold' }
      },
      {
        id: 'nav-links',
        type: 'container',
        name: 'Links Container',
        props: {},
        styles: { display: 'flex', gap: '1.5rem' },
        children: [
          { id: 'link-1', type: 'text', name: 'Link 1', props: { tag: 'span', content: 'Home' }, styles: { cursor: 'pointer' } },
          { id: 'link-2', type: 'text', name: 'Link 2', props: { tag: 'span', content: 'About' }, styles: { cursor: 'pointer' } },
          { id: 'link-3', type: 'text', name: 'Link 3', props: { tag: 'span', content: 'Contact' }, styles: { cursor: 'pointer' } }
        ]
      }
    ]
  },
  'login-form': {
    id: 'login',
    type: 'card',
    name: 'Login Form',
    props: {},
    styles: {
      maxWidth: '400px',
      margin: '2rem auto',
      padding: '2rem',
      display: 'flex',
      flexDirection: 'column',
      gap: '1rem',
      backgroundColor: 'hsl(var(--card))',
      border: '1px solid hsl(var(--border))',
      borderRadius: 'var(--radius)'
    },
    children: [
      {
        id: 'login-title',
        type: 'text',
        name: 'Login Title',
        props: { tag: 'h2', content: 'Welcome Back' },
        styles: { textAlign: 'center', marginBottom: '1rem' }
      },
      {
        id: 'email-input',
        type: 'input',
        name: 'Email Input',
        props: { placeholder: 'Email address' },
        styles: { padding: '0.75rem', borderRadius: 'var(--radius)', border: '1px solid hsl(var(--input))' }
      },
      {
        id: 'pass-input',
        type: 'input',
        name: 'Password Input',
        props: { placeholder: 'Password', type: 'password' },
        styles: { padding: '0.75rem', borderRadius: 'var(--radius)', border: '1px solid hsl(var(--input))' }
      },
      {
        id: 'login-btn',
        type: 'button',
        name: 'Login Button',
        props: { label: 'Sign In' },
        styles: { 
            padding: '0.75rem', 
            backgroundColor: 'hsl(var(--primary))', 
            color: 'white', 
            border: 'none', 
            borderRadius: 'var(--radius)',
            fontWeight: '600',
            marginTop: '0.5rem'
        }
      }
    ]
  }
};
