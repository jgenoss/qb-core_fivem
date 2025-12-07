import React, { useState, useEffect, useCallback } from 'react';
import { 
  ResizableHandle, 
  ResizablePanel, 
  ResizablePanelGroup 
} from "@/components/ui/resizable";
import { 
  Layout, Type, Box, Image as ImageIcon, MousePointer2, Code, Play, 
  Settings, Layers, Plus, Trash2, Monitor, Smartphone, Tablet, Download, 
  ChevronRight, ChevronDown, Hash, Database, Zap, Eye, X, Copy, CopyPlus, 
  ArrowUp, ArrowDown, Undo2, Redo2, Palette, Component, GripVertical
} from "lucide-react";
import { ScrollArea } from "@/components/ui/scroll-area";
import { Button } from "@/components/ui/button";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Separator } from "@/components/ui/separator";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Textarea } from "@/components/ui/textarea";
import { Accordion, AccordionContent, AccordionItem, AccordionTrigger } from "@/components/ui/accordion";
import { Dialog, DialogContent, DialogTrigger, DialogClose, DialogTitle, DialogHeader } from "@/components/ui/dialog";
import { Slider } from "@/components/ui/slider";
import {
  ContextMenu, ContextMenuContent, ContextMenuItem, ContextMenuTrigger, 
  ContextMenuSeparator, ContextMenuShortcut,
} from "@/components/ui/context-menu";
import { 
  DndContext, closestCenter, KeyboardSensor, PointerSensor, useSensor, 
  useSensors, DragEndEvent 
} from '@dnd-kit/core';
import {
  arrayMove, SortableContext, sortableKeyboardCoordinates, verticalListSortingStrategy, 
  useSortable
} from '@dnd-kit/sortable';
import { CSS } from '@dnd-kit/utilities';

import { initialElements, UIElement, ElementType, prebuiltBlocks, GlobalStyles, defaultGlobalStyles } from "@/lib/builder-types";
import { cn } from "@/lib/utils";

// Sortable Tree Item Component
const SortableTreeItem = ({ el, depth, isSelected, onClick, onHover, onOut, children }: any) => {
  const {
    attributes,
    listeners,
    setNodeRef,
    transform,
    transition,
  } = useSortable({ id: el.id });

  const style = {
    transform: CSS.Transform.toString(transform),
    transition,
    paddingLeft: `${depth * 12 + 8}px`
  };

  return (
    <div ref={setNodeRef} style={style} {...attributes}>
        <ContextMenu>
            <ContextMenuTrigger>
              <div 
                className={cn(
                    "flex items-center py-1 px-2 text-xs cursor-pointer select-none hover:bg-muted/50 border-l-2 group", 
                    isSelected ? "bg-muted text-primary border-primary font-medium" : "border-transparent text-muted-foreground"
                )}
                onClick={onClick}
                onMouseOver={onHover}
                onMouseOut={onOut}
              >
                 <div className="mr-1 opacity-0 group-hover:opacity-100 cursor-grab active:cursor-grabbing" {...listeners}>
                    <GripVertical className="h-3 w-3 text-muted-foreground" />
                 </div>
                 {el.type === 'container' || el.type === 'grid' ? <Box className="h-3 w-3 mr-2 opacity-70" /> :
                  el.type === 'text' ? <Type className="h-3 w-3 mr-2 opacity-70" /> :
                  el.type === 'button' ? <MousePointer2 className="h-3 w-3 mr-2 opacity-70" /> :
                  el.type === 'image' ? <ImageIcon className="h-3 w-3 mr-2 opacity-70" /> :
                  el.type === 'input' ? <Code className="h-3 w-3 mr-2 opacity-70" /> :
                  <Layout className="h-3 w-3 mr-2 opacity-70" />
                 }
                 <span className="truncate">{el.name}</span>
              </div>
            </ContextMenuTrigger>
             {children}
        </ContextMenu>
    </div>
  );
};

export default function Builder() {
  // Main State
  const [elements, setElements] = useState<UIElement[]>(initialElements);
  const [globalStyles, setGlobalStyles] = useState<GlobalStyles>(defaultGlobalStyles);
  const [selectedId, setSelectedId] = useState<string | null>('root');
  const [hoveredId, setHoveredId] = useState<string | null>(null);
  
  // UI State
  const [previewMode, setPreviewMode] = useState<'desktop' | 'tablet' | 'mobile'>('desktop');
  const [activeTab, setActiveTab] = useState('design'); 
  const [isPreviewOpen, setIsPreviewOpen] = useState(false);
  const [leftSidebarTab, setLeftSidebarTab] = useState('add');

  // History State (Undo/Redo)
  const [history, setHistory] = useState<{elements: UIElement[], globalStyles: GlobalStyles}[]>([{elements: initialElements, globalStyles: defaultGlobalStyles}]);
  const [historyIndex, setHistoryIndex] = useState(0);

  // DnD Sensors
  const sensors = useSensors(
    useSensor(PointerSensor),
    useSensor(KeyboardSensor, {
      coordinateGetter: sortableKeyboardCoordinates,
    })
  );

  // --- History Management ---
  const pushToHistory = useCallback((newElements: UIElement[], newGlobalStyles: GlobalStyles) => {
    const newHistory = history.slice(0, historyIndex + 1);
    newHistory.push({ elements: newElements, globalStyles: newGlobalStyles });
    
    // Limit history size if needed (e.g. 50 steps)
    if (newHistory.length > 50) newHistory.shift();
    
    setHistory(newHistory);
    setHistoryIndex(newHistory.length - 1);
  }, [history, historyIndex]);

  const undo = () => {
    if (historyIndex > 0) {
      setHistoryIndex(historyIndex - 1);
      setElements(history[historyIndex - 1].elements);
      setGlobalStyles(history[historyIndex - 1].globalStyles);
    }
  };

  const redo = () => {
    if (historyIndex < history.length - 1) {
      setHistoryIndex(historyIndex + 1);
      setElements(history[historyIndex + 1].elements);
      setGlobalStyles(history[historyIndex + 1].globalStyles);
    }
  };

  // Wrapper for setting elements that pushes to history
  const updateElementsWithHistory = (newElements: UIElement[]) => {
    setElements(newElements);
    pushToHistory(newElements, globalStyles);
  };

  // Wrapper for setting global styles that pushes to history
  const updateGlobalStylesWithHistory = (newStyles: GlobalStyles) => {
    setGlobalStyles(newStyles);
    pushToHistory(elements, newStyles);
  };

  // --- Element Management ---

  // Find element helper
  const findElement = useCallback((id: string, list: UIElement[]): UIElement | null => {
    for (const el of list) {
      if (el.id === id) return el;
      if (el.children) {
        const found = findElement(id, el.children);
        if (found) return found;
      }
    }
    return null;
  }, []);

  const selectedElement = selectedId ? findElement(selectedId, elements) : null;

  // Breadcrumbs helper
  const getBreadcrumbs = (id: string, list: UIElement[], path: UIElement[] = []): UIElement[] | null => {
    for (const el of list) {
      if (el.id === id) return [...path, el];
      if (el.children) {
        const found = getBreadcrumbs(id, el.children, [...path, el]);
        if (found) return found;
      }
    }
    return null;
  };
  const breadcrumbs = selectedId ? getBreadcrumbs(selectedId, elements) : [];

  // Update element props/styles
  const updateElement = (id: string, updates: Partial<UIElement>) => {
    const updateRecursive = (list: UIElement[]): UIElement[] => {
      return list.map(el => {
        if (el.id === id) {
          return { ...el, ...updates };
        }
        if (el.children) {
          return { ...el, children: updateRecursive(el.children) };
        }
        return el;
      });
    };
    updateElementsWithHistory(updateRecursive(elements));
  };

  // Add new element (Basic or Block)
  const addElement = (type: string, isBlock = false) => {
    // If it's a block, we clone the prebuilt structure
    let newEl: UIElement;
    
    if (isBlock && prebuiltBlocks[type]) {
       // Deep clone the block to avoid reference issues
       newEl = JSON.parse(JSON.stringify(prebuiltBlocks[type]));
       newEl.id = `${type}-${Date.now()}`; // Ensure root ID is unique
    } else {
       // Create basic element
       const elType = type as ElementType;
       newEl = {
        id: `${elType}-${Date.now()}`,
        type: elType,
        name: `New ${elType}`,
        props: elType === 'text' ? { content: 'Double click to edit', tag: 'p' } : 
               elType === 'button' ? { label: 'Button', variant: 'primary' } : {},
        styles: elType === 'container' ? { padding: '1rem', border: '1px dashed hsl(var(--border))', minHeight: '50px' } : 
                elType === 'card' ? { padding: '1.5rem', backgroundColor: 'hsl(var(--card))', borderRadius: 'var(--radius)', border: '1px solid hsl(var(--border))' } : {},
        children: elType === 'container' || elType === 'card' || elType === 'grid' ? [] : undefined
      };
    }

    // Add to tree
    const targetId = selectedId || 'root';
    const addRecursive = (list: UIElement[]): UIElement[] => {
      const targetEl = findElement(targetId, list);
      const canAcceptChildren = targetEl && (targetEl.type === 'container' || targetEl.type === 'card' || targetEl.type === 'grid' || targetEl.id === 'root');
      const actualTargetId = canAcceptChildren ? targetId : 'root';

      return list.map(el => {
        if (el.id === actualTargetId) {
          return { ...el, children: [...(el.children || []), newEl] };
        }
        if (el.children) {
          return { ...el, children: addRecursive(el.children) };
        }
        return el;
      });
    };
    
    updateElementsWithHistory(addRecursive(elements));
    setSelectedId(newEl.id);
  };

  const deleteElement = (id: string) => {
    if (id === 'root') return;
    const deleteRecursive = (list: UIElement[]): UIElement[] => {
      return list.filter(el => el.id !== id).map(el => ({
        ...el,
        children: el.children ? deleteRecursive(el.children) : undefined
      }));
    };
    updateElementsWithHistory(deleteRecursive(elements));
    setSelectedId(null);
  };

  const duplicateElement = (id: string) => {
    if (id === 'root') return;
    const cloneRecursive = (el: UIElement): UIElement => {
       const newId = `${el.type}-${Date.now()}-${Math.floor(Math.random() * 1000)}`;
       return {
         ...el,
         id: newId,
         name: `${el.name} (Copy)`,
         children: el.children ? el.children.map(cloneRecursive) : undefined
       };
    };
    const insertRecursive = (list: UIElement[]): UIElement[] => {
        let newList: UIElement[] = [];
        for (const el of list) {
            newList.push(el);
            if (el.id === id) newList.push(cloneRecursive(el));
            if (el.children) el.children = insertRecursive(el.children);
        }
        return newList;
    };
    updateElementsWithHistory(insertRecursive([...elements])); 
  };

  // DnD Handler
  const handleDragEnd = (event: DragEndEvent) => {
    const { active, over } = event;
    if (!over || active.id === over.id) return;

    // This is a simplified tree sort implementation
    // Ideally we would need a more complex logic to handle nesting via drag
    // For now, we search for the parent array containing the items and reorder them
    
    const reorderRecursive = (list: UIElement[]): UIElement[] => {
        // Check if this list contains both items
        const activeIndex = list.findIndex(el => el.id === active.id);
        const overIndex = list.findIndex(el => el.id === over.id);
        
        if (activeIndex !== -1 && overIndex !== -1) {
            return arrayMove(list, activeIndex, overIndex);
        }
        
        return list.map(el => ({
            ...el,
            children: el.children ? reorderRecursive(el.children) : undefined
        }));
    };
    
    updateElementsWithHistory(reorderRecursive(elements));
  };


  // --- Renderers ---

  const renderElement = (el: UIElement, isLivePreview = false) => {
    const isSelected = !isLivePreview && selectedId === el.id;
    const isHovered = !isLivePreview && hoveredId === el.id && !isSelected;
    
    const commonProps = {
      key: el.id,
      onClick: (e: React.MouseEvent) => {
        if (!isLivePreview) {
          e.stopPropagation();
          setSelectedId(el.id);
        } else if (el.props.onClick) {
            alert(`Interaction: ${el.props.onClick} triggered!`);
        }
      },
      onMouseOver: (e: React.MouseEvent) => {
        if (!isLivePreview) {
          e.stopPropagation();
          setHoveredId(el.id);
        }
      },
      onMouseOut: (e: React.MouseEvent) => {
        if (!isLivePreview) {
          e.stopPropagation();
          setHoveredId(null);
        }
      },
      className: cn(
        "relative transition-all duration-200",
        !isLivePreview && isSelected && "outline outline-2 outline-primary outline-offset-[-1px] z-10",
        !isLivePreview && isHovered && "outline outline-1 outline-primary/50 outline-offset-[-1px] z-20 cursor-pointer",
        isLivePreview && el.props.onClick && "cursor-pointer active:scale-[0.98] transition-transform"
      ),
      style: { 
          ...el.styles,
          // Apply global styles vars if needed, though they are usually CSS vars
       }
    };

    // Label overlay
    const LabelOverlay = () => (
      (!isLivePreview && (isSelected || isHovered)) ? (
        <div className={cn(
          "absolute -top-5 left-0 px-1.5 py-0.5 text-[10px] font-mono rounded-t text-white pointer-events-none whitespace-nowrap z-50",
          isSelected ? "bg-primary" : "bg-primary/50"
        )}>
          {el.name}
        </div>
      ) : null
    );

    // Context Menu Wrapper
    const Wrapper = ({ children }: { children: React.ReactNode }) => {
        if (isLivePreview) return <>{children}</>;
        return (
             <ContextMenu>
                <ContextMenuTrigger asChild>{children}</ContextMenuTrigger>
                <ContextMenuContent className="w-64">
                   <ContextMenuItem inset disabled><span className="font-semibold">{el.name}</span></ContextMenuItem>
                   <ContextMenuSeparator />
                   <ContextMenuItem inset onClick={() => duplicateElement(el.id)}>
                      Duplicate <ContextMenuShortcut><CopyPlus className="h-4 w-4" /></ContextMenuShortcut>
                   </ContextMenuItem>
                   <ContextMenuSeparator />
                   <ContextMenuItem inset className="text-destructive focus:text-destructive" onClick={() => deleteElement(el.id)}>
                      Delete <ContextMenuShortcut><Trash2 className="h-4 w-4" /></ContextMenuShortcut>
                   </ContextMenuItem>
                </ContextMenuContent>
             </ContextMenu>
        );
    }

    let content;
    if (el.type === 'container' || el.type === 'card' || el.type === 'grid') {
      content = (
        <div {...commonProps}>
          <LabelOverlay />
          {el.children?.map(child => renderElement(child, isLivePreview))}
          {!isLivePreview && el.children?.length === 0 && (
            <div className="w-full h-full min-h-[40px] flex items-center justify-center text-xs text-muted-foreground/30 border border-dashed border-muted-foreground/20 rounded bg-muted/5 pointer-events-none select-none">
              Empty {el.name}
            </div>
          )}
        </div>
      );
    } else if (el.type === 'text') {
      const Tag = (el.props.tag || 'p') as any;
      content = <Tag {...commonProps}><LabelOverlay />{el.props.content}</Tag>;
    } else if (el.type === 'button') {
      content = <button {...commonProps}><LabelOverlay />{el.props.label}</button>;
    } else if (el.type === 'input') {
      content = (
        <div className="relative group" onClick={commonProps.onClick} onMouseOver={commonProps.onMouseOver} onMouseOut={commonProps.onMouseOut} style={{ display: 'inline-block', width: el.styles?.width || '100%' }}>
            <LabelOverlay />
            <input className={cn(commonProps.className)} style={el.styles} placeholder={el.props.placeholder || 'Input...'} disabled={!isLivePreview} />
        </div>
      );
    } else {
      content = <div {...commonProps}><LabelOverlay />Unknown Element</div>;
    }

    return <Wrapper>{content}</Wrapper>;
  };

  // Tree Item Renderer (Recursive)
  const renderTreeItem = (el: UIElement, depth = 0) => {
      const item = (
         <SortableTreeItem
            key={el.id}
            el={el}
            depth={depth}
            isSelected={selectedId === el.id}
            onClick={(e: any) => { e.stopPropagation(); setSelectedId(el.id); }}
            onHover={(e: any) => { e.stopPropagation(); setHoveredId(el.id); }}
            onOut={(e: any) => { e.stopPropagation(); setHoveredId(null); }}
         >
            {/* This context menu is already inside SortableTreeItem */}
            <ContextMenuContent>
               <ContextMenuItem onClick={() => duplicateElement(el.id)}>Duplicate</ContextMenuItem>
               <ContextMenuItem onClick={() => deleteElement(el.id)}>Delete</ContextMenuItem>
            </ContextMenuContent>
         </SortableTreeItem>
      );

      if (el.children && el.children.length > 0) {
          return (
              <React.Fragment key={el.id}>
                  {item}
                  <SortableContext items={el.children.map(c => c.id)} strategy={verticalListSortingStrategy}>
                      {el.children.map(child => renderTreeItem(child, depth + 1))}
                  </SortableContext>
              </React.Fragment>
          );
      }
      return item;
  };

  // Code Generation
  const generateCode = () => {
    // Generate CSS variables root
    const cssVars = `:root {
  --primary: ${globalStyles.primaryColor};
  --radius: ${globalStyles.borderRadius};
  --font-sans: ${globalStyles.fontFamily};
}`;
    return `<template>\n  <div class="app-container">\n    <!-- Generated by WebStudio -->\n  </div>\n</template>\n\n<style>\n${cssVars}\n.app-container { font-family: var(--font-sans); }\n</style>`;
  }

  // --- Main Layout ---
  return (
    <div className="h-screen w-full bg-background flex flex-col overflow-hidden text-foreground" style={{
        '--primary': `hsl(${globalStyles.primaryColor})`,
        '--radius': globalStyles.borderRadius,
    } as React.CSSProperties}>
      
      {/* Top Bar */}
      <header className="h-14 border-b border-border bg-sidebar flex items-center px-4 justify-between shrink-0 z-50">
        <div className="flex items-center gap-3">
          <div className="h-8 w-8 bg-primary rounded-md flex items-center justify-center text-primary-foreground font-bold shadow-lg shadow-primary/20">WS</div>
          <div>
            <div className="font-semibold text-sm leading-none">WebStudio Pro</div>
            <div className="text-[10px] text-muted-foreground mt-1">v3.0.0</div>
          </div>
        </div>

        {/* Undo/Redo & View Controls */}
        <div className="flex items-center gap-4">
             <div className="flex items-center bg-muted/30 rounded-md border border-border/50 p-0.5">
                 <Button variant="ghost" size="icon" className="h-7 w-7" onClick={undo} disabled={historyIndex <= 0}>
                    <Undo2 className="h-4 w-4" />
                 </Button>
                 <Button variant="ghost" size="icon" className="h-7 w-7" onClick={redo} disabled={historyIndex >= history.length - 1}>
                    <Redo2 className="h-4 w-4" />
                 </Button>
             </div>

             <div className="flex items-center gap-1 bg-muted/30 p-1 rounded-md border border-border/50">
                <Button variant="ghost" size="sm" className={cn("h-7 px-3 gap-2", previewMode === 'desktop' && "bg-background shadow-sm")} onClick={() => setPreviewMode('desktop')}>
                    <Monitor className="h-3.5 w-3.5" />
                </Button>
                <Button variant="ghost" size="sm" className={cn("h-7 px-3 gap-2", previewMode === 'tablet' && "bg-background shadow-sm")} onClick={() => setPreviewMode('tablet')}>
                    <Tablet className="h-3.5 w-3.5" />
                </Button>
                <Button variant="ghost" size="sm" className={cn("h-7 px-3 gap-2", previewMode === 'mobile' && "bg-background shadow-sm")} onClick={() => setPreviewMode('mobile')}>
                    <Smartphone className="h-3.5 w-3.5" />
                </Button>
            </div>
        </div>

        <div className="flex items-center gap-2">
          <Button variant="outline" size="sm" className="gap-2 h-8 text-xs" onClick={() => setIsPreviewOpen(true)}>
            <Play className="h-3 w-3" /> Preview
          </Button>
          <Button size="sm" className="gap-2 h-8 text-xs bg-primary hover:bg-primary/90 text-primary-foreground">
            <Download className="h-3 w-3" /> Export
          </Button>
        </div>
      </header>

      {/* Main Workspace */}
      <div className="flex-1 flex overflow-hidden">
        <ResizablePanelGroup direction="horizontal">
          
          {/* Left Sidebar */}
          <ResizablePanel defaultSize={20} minSize={15} maxSize={25} className="bg-sidebar border-r border-border flex flex-col">
             <Tabs value={leftSidebarTab} onValueChange={setLeftSidebarTab} className="flex-1 flex flex-col">
                <div className="px-2 pt-2">
                  <TabsList className="w-full grid grid-cols-3">
                    <TabsTrigger value="add" className="text-xs">Add</TabsTrigger>
                    <TabsTrigger value="blocks" className="text-xs">Blocks</TabsTrigger>
                    <TabsTrigger value="layers" className="text-xs">Layers</TabsTrigger>
                  </TabsList>
                </div>
                
                {/* Basic Components */}
                <TabsContent value="add" className="flex-1 overflow-hidden flex flex-col m-0 p-0">
                  <ScrollArea className="flex-1">
                    <div className="p-4 space-y-6">
                        <div className="space-y-3">
                            <div className="text-[10px] font-semibold text-muted-foreground uppercase tracking-wider">Layout</div>
                            <div className="grid grid-cols-2 gap-2">
                                <Button variant="outline" className="h-auto py-3 flex flex-col gap-2 bg-muted/5" onClick={() => addElement('container')}>
                                    <Box className="h-5 w-5 opacity-70" /><span className="text-[10px]">Container</span>
                                </Button>
                                <Button variant="outline" className="h-auto py-3 flex flex-col gap-2 bg-muted/5" onClick={() => addElement('grid')}>
                                    <Layout className="h-5 w-5 opacity-70" /><span className="text-[10px]">Grid</span>
                                </Button>
                                <Button variant="outline" className="h-auto py-3 flex flex-col gap-2 bg-muted/5" onClick={() => addElement('card')}>
                                    <Layers className="h-5 w-5 opacity-70" /><span className="text-[10px]">Card</span>
                                </Button>
                            </div>
                        </div>
                        <div className="space-y-3">
                            <div className="text-[10px] font-semibold text-muted-foreground uppercase tracking-wider">Basic</div>
                            <div className="grid grid-cols-2 gap-2">
                                <Button variant="outline" className="h-auto py-3 flex flex-col gap-2 bg-muted/5" onClick={() => addElement('text')}>
                                    <Type className="h-5 w-5 opacity-70" /><span className="text-[10px]">Text</span>
                                </Button>
                                <Button variant="outline" className="h-auto py-3 flex flex-col gap-2 bg-muted/5" onClick={() => addElement('button')}>
                                    <MousePointer2 className="h-5 w-5 opacity-70" /><span className="text-[10px]">Button</span>
                                </Button>
                                <Button variant="outline" className="h-auto py-3 flex flex-col gap-2 bg-muted/5" onClick={() => addElement('image')}>
                                    <ImageIcon className="h-5 w-5 opacity-70" /><span className="text-[10px]">Image</span>
                                </Button>
                                <Button variant="outline" className="h-auto py-3 flex flex-col gap-2 bg-muted/5" onClick={() => addElement('input')}>
                                    <Code className="h-5 w-5 opacity-70" /><span className="text-[10px]">Input</span>
                                </Button>
                            </div>
                        </div>
                    </div>
                  </ScrollArea>
                </TabsContent>

                {/* Prebuilt Blocks */}
                <TabsContent value="blocks" className="flex-1 overflow-hidden flex flex-col m-0 p-0">
                    <ScrollArea className="flex-1">
                        <div className="p-4 space-y-4">
                            <div className="text-[10px] font-semibold text-muted-foreground uppercase tracking-wider">Sections</div>
                            {Object.keys(prebuiltBlocks).map(key => (
                                <div 
                                    key={key} 
                                    className="border border-border rounded-md p-3 hover:border-primary cursor-pointer bg-muted/5 group transition-all"
                                    onClick={() => addElement(key, true)}
                                >
                                    <div className="flex items-center justify-between mb-2">
                                        <span className="text-sm font-medium capitalize">{key.replace('-', ' ')}</span>
                                        <Plus className="h-4 w-4 opacity-0 group-hover:opacity-100 text-primary" />
                                    </div>
                                    <div className="h-16 bg-muted/20 rounded border border-dashed border-muted flex items-center justify-center">
                                        <Component className="h-6 w-6 text-muted-foreground/30" />
                                    </div>
                                </div>
                            ))}
                        </div>
                    </ScrollArea>
                </TabsContent>
                
                {/* Layers Tree with DnD */}
                <TabsContent value="layers" className="flex-1 overflow-hidden flex flex-col m-0 p-0">
                   <ScrollArea className="flex-1 bg-muted/5">
                      <div className="py-2">
                        <DndContext 
                            sensors={sensors} 
                            collisionDetection={closestCenter}
                            onDragEnd={handleDragEnd}
                        >
                            <SortableContext items={elements.map(e => e.id)} strategy={verticalListSortingStrategy}>
                                {elements.map(el => renderTreeItem(el))}
                            </SortableContext>
                        </DndContext>
                      </div>
                   </ScrollArea>
                </TabsContent>
             </Tabs>
          </ResizablePanel>
          
          <ResizableHandle className="bg-border" />
          
          {/* Center Canvas */}
          <ResizablePanel defaultSize={55} className="bg-muted/20 relative flex flex-col">
             <Tabs value={activeTab} onValueChange={setActiveTab} className="h-full flex flex-col">
               <div className="h-10 border-b border-border bg-background flex items-center px-4 justify-between shrink-0">
                 <TabsList className="h-7 p-0.5 bg-muted/50">
                   <TabsTrigger value="design" className="text-[10px] h-6 px-3">Visual Editor</TabsTrigger>
                   <TabsTrigger value="code" className="text-[10px] h-6 px-3">Code Preview</TabsTrigger>
                 </TabsList>
                 <div className="flex items-center gap-1 text-[10px] text-muted-foreground overflow-hidden max-w-[300px]">
                   {breadcrumbs?.map((crumb, i) => (
                     <React.Fragment key={crumb.id}>
                       {i > 0 && <ChevronRight className="h-3 w-3 opacity-50" />}
                       <span className={cn("cursor-pointer hover:text-foreground truncate", i === breadcrumbs.length - 1 && "font-medium text-foreground")} onClick={() => setSelectedId(crumb.id)}>{crumb.name}</span>
                     </React.Fragment>
                   ))}
                 </div>
               </div>

               <TabsContent value="design" className="flex-1 overflow-hidden relative m-0 p-0 group/canvas">
                  <div className="absolute inset-0 overflow-auto bg-grid-pattern flex justify-center p-8 pb-20">
                    <div 
                      className={cn(
                        "bg-background shadow-2xl transition-all duration-300 origin-top border border-border/50 ring-1 ring-black/5",
                        previewMode === 'desktop' ? 'w-full max-w-[1000px]' : previewMode === 'tablet' ? 'w-[768px]' : 'w-[375px]'
                      )}
                      style={{ minHeight: '800px' }}
                      onClick={() => setSelectedId(null)}
                    >
                      {elements.map(el => renderElement(el))}
                    </div>
                  </div>
               </TabsContent>
               <TabsContent value="code" className="flex-1 m-0 overflow-hidden">
                 <ScrollArea className="h-full bg-[#1e1e1e] text-[#d4d4d4]">
                   <div className="p-4 font-mono text-xs leading-relaxed"><pre>{generateCode()}</pre></div>
                 </ScrollArea>
               </TabsContent>
             </Tabs>
          </ResizablePanel>
          
          <ResizableHandle className="bg-border" />
          
          {/* Right Sidebar */}
          <ResizablePanel defaultSize={25} minSize={20} maxSize={30} className="bg-sidebar border-l border-border flex flex-col">
            <Tabs defaultValue="props" className="flex-1 flex flex-col">
                <div className="h-10 border-b border-border flex items-center px-4 justify-between bg-muted/5">
                    <TabsList className="h-7 p-0.5 bg-muted/50 w-full">
                        <TabsTrigger value="props" className="text-[10px] h-6 flex-1">Properties</TabsTrigger>
                        <TabsTrigger value="theme" className="text-[10px] h-6 flex-1">Theme</TabsTrigger>
                    </TabsList>
                </div>
                
                <TabsContent value="props" className="flex-1 overflow-hidden m-0">
                    <ScrollArea className="h-full">
                    {selectedElement ? (
                        <div className="p-4 space-y-6">
                        <div className="space-y-3">
                            <div className="space-y-1">
                                <Label className="text-[10px] uppercase text-muted-foreground">ID</Label>
                                <div className="flex gap-2">
                                <div className="relative flex-1">
                                    <Hash className="absolute left-2 top-1.5 h-3.5 w-3.5 text-muted-foreground" />
                                    <Input value={selectedElement.id} disabled className="h-7 pl-7 text-xs bg-muted/20 font-mono" />
                                </div>
                                </div>
                            </div>
                            <div className="space-y-1">
                                <Label className="text-[10px] uppercase text-muted-foreground">Name</Label>
                                <Input value={selectedElement.name} onChange={(e) => updateElement(selectedElement.id, { name: e.target.value })} className="h-7 text-xs" />
                            </div>
                        </div>
                        <Separator />
                        <Accordion type="multiple" defaultValue={['content', 'styles']}>
                            <AccordionItem value="content" className="border-b-0">
                                <AccordionTrigger className="py-2 text-xs font-semibold hover:no-underline">Content</AccordionTrigger>
                                <AccordionContent className="space-y-3 pt-2">
                                    {(selectedElement.type === 'text' || selectedElement.type === 'button') && (
                                        <div className="space-y-2">
                                            <Label className="text-[10px]">Text / Label</Label>
                                            <Input 
                                                value={selectedElement.props.content || selectedElement.props.label || ''} 
                                                onChange={(e) => {
                                                    const key = selectedElement.type === 'button' ? 'label' : 'content';
                                                    updateElement(selectedElement.id, { props: { ...selectedElement.props, [key]: e.target.value } });
                                                }} 
                                                className="h-7 text-xs"
                                            />
                                        </div>
                                    )}
                                    <div className="space-y-2">
                                        <Label className="text-[10px]">HTML Tag</Label>
                                        <Input 
                                            value={selectedElement.props.tag || 'div'} 
                                            onChange={(e) => updateElement(selectedElement.id, { props: { ...selectedElement.props, tag: e.target.value } })} 
                                            className="h-7 text-xs"
                                        />
                                    </div>
                                </AccordionContent>
                            </AccordionItem>
                            <AccordionItem value="styles" className="border-b-0">
                                <AccordionTrigger className="py-2 text-xs font-semibold hover:no-underline">Styles</AccordionTrigger>
                                <AccordionContent className="space-y-3 pt-2">
                                    <div className="grid grid-cols-2 gap-2">
                                         <div className="space-y-1">
                                            <Label className="text-[10px]">Padding</Label>
                                            <Input value={selectedElement.styles?.padding || ''} onChange={(e) => updateElement(selectedElement.id, { styles: { ...selectedElement.styles, padding: e.target.value } })} className="h-7 text-xs" />
                                         </div>
                                         <div className="space-y-1">
                                            <Label className="text-[10px]">Margin</Label>
                                            <Input value={selectedElement.styles?.margin || ''} onChange={(e) => updateElement(selectedElement.id, { styles: { ...selectedElement.styles, margin: e.target.value } })} className="h-7 text-xs" />
                                         </div>
                                         <div className="space-y-1">
                                            <Label className="text-[10px]">Bg Color</Label>
                                            <Input value={selectedElement.styles?.backgroundColor || ''} onChange={(e) => updateElement(selectedElement.id, { styles: { ...selectedElement.styles, backgroundColor: e.target.value } })} className="h-7 text-xs" />
                                         </div>
                                         <div className="space-y-1">
                                            <Label className="text-[10px]">Text Color</Label>
                                            <Input value={selectedElement.styles?.color || ''} onChange={(e) => updateElement(selectedElement.id, { styles: { ...selectedElement.styles, color: e.target.value } })} className="h-7 text-xs" />
                                         </div>
                                    </div>
                                </AccordionContent>
                            </AccordionItem>
                        </Accordion>
                        </div>
                    ) : (
                        <div className="flex flex-col items-center justify-center h-full text-muted-foreground p-8 text-center space-y-2">
                        <MousePointer2 className="h-6 w-6 opacity-50" />
                        <div className="text-sm font-medium">No Selection</div>
                        </div>
                    )}
                    </ScrollArea>
                </TabsContent>

                {/* Global Theme Editor */}
                <TabsContent value="theme" className="flex-1 overflow-hidden m-0">
                    <ScrollArea className="h-full">
                        <div className="p-4 space-y-6">
                            <div className="flex items-center gap-2 mb-2">
                                <Palette className="h-4 w-4 text-primary" />
                                <h3 className="text-sm font-semibold">Global Styles</h3>
                            </div>
                            
                            <div className="space-y-4">
                                <div className="space-y-2">
                                    <Label className="text-xs">Primary Color (HSL)</Label>
                                    <div className="flex gap-2">
                                        <div className="h-8 w-8 rounded border" style={{ backgroundColor: `hsl(${globalStyles.primaryColor})` }} />
                                        <Input 
                                            value={globalStyles.primaryColor} 
                                            onChange={(e) => updateGlobalStylesWithHistory({ ...globalStyles, primaryColor: e.target.value })}
                                            className="h-8 flex-1 font-mono text-xs"
                                        />
                                    </div>
                                </div>
                                <div className="space-y-2">
                                    <Label className="text-xs">Font Family</Label>
                                    <Input 
                                        value={globalStyles.fontFamily} 
                                        onChange={(e) => updateGlobalStylesWithHistory({ ...globalStyles, fontFamily: e.target.value })}
                                        className="h-8 text-xs"
                                    />
                                </div>
                                <div className="space-y-2">
                                    <Label className="text-xs">Border Radius</Label>
                                    <Input 
                                        value={globalStyles.borderRadius} 
                                        onChange={(e) => updateGlobalStylesWithHistory({ ...globalStyles, borderRadius: e.target.value })}
                                        className="h-8 text-xs"
                                    />
                                </div>
                            </div>
                        </div>
                    </ScrollArea>
                </TabsContent>
            </Tabs>
          </ResizablePanel>
          
        </ResizablePanelGroup>
      </div>

      {/* Preview Dialog */}
      <Dialog open={isPreviewOpen} onOpenChange={setIsPreviewOpen}>
            <DialogContent className="max-w-[90vw] h-[90vh] flex flex-col p-0 gap-0">
               <DialogHeader className="h-12 border-b border-border flex flex-row items-center px-4 justify-between bg-sidebar">
                  <DialogTitle className="text-sm">App Preview</DialogTitle>
               </DialogHeader>
               <div className="flex-1 bg-background overflow-auto p-8 flex justify-center" style={{
                    '--primary': `hsl(${globalStyles.primaryColor})`,
                    '--radius': globalStyles.borderRadius,
                    fontFamily: globalStyles.fontFamily
               } as React.CSSProperties}>
                  <div className="w-full max-w-[1000px]">
                     {elements.map(el => renderElement(el, true))}
                  </div>
               </div>
            </DialogContent>
      </Dialog>
    </div>
  );
}
