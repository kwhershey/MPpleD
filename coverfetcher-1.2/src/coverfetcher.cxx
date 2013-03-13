/*
 * coverfetcher.cxx: Simple last.fm cover fetcher.
 * Author: Benjamin Johnson <obeythepenguin@users.sf.net>
 * Date: 2011/02/25
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301
 */

#include <qapplication.h>
#include <curlwrapper.h>

#include "fetcher.h"

/*
 * Main application loop.
 */
int main(int argc, char **argv)
{
	QApplication app(argc, argv);
	QWidget::connect(&app, SIGNAL(lastWindowClosed()),
							&app, SLOT(quit()));

#ifdef	Q_WS_WIN
	QApplication::setFont(QFont("Tahoma", 8));
	QFont::insertSubstitution("Tahoma", "Arial");
#endif	// Q_WS_WIN

	// initialize libcurl
	CurlWrapper::init();

	// create the main window
	CoverFetcher *fetcher = new CoverFetcher;
	fetcher->show();

	int retval = app.exec();

	// clean up libcurl
	CurlWrapper::cleanup();

	delete fetcher;
	return retval;
}
