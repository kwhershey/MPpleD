#ifndef PREVIEW_H_
#define PREVIEW_H_

#include <qlabel.h>
#include <qfiledialog.h>
#include <qpopupmenu.h>
#include <qimage.h>

class CoverPreview : public QLabel, public QFilePreview
{
	public:
		CoverPreview(QWidget *parent = 0, const char *name = 0);
		CoverPreview(QWidget *parent, const QImage &coverData);
		~CoverPreview();

		void previewUrl(const QUrl &u);
		void setCoverData(const QImage &coverData);
		void setCoverName(const QString &coverName);

		void setDragEnabled(bool enabled);
		void setContextMenu(QPopupMenu *menu);

	protected:
		QImage coverData;
		QString coverName;
		QString tempFilename;

		bool dragEnabled;
		QPopupMenu *contextMenu;	// pointer; don't delete!

		void init();
		void startImageDrag();
		void startImageUriDrag();

		void mouseMoveEvent(QMouseEvent *e);
		void contextMenuEvent(QContextMenuEvent *e);

		void saveLastCover();
		void clearLastCover();
};

#endif  // PREVIEW_H_
